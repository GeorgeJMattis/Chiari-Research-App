//
//  BaselineResponse.swift
//  Chiari Research App
//
//  One participant's answers to one baseline questionnaire. Keyed by the
//  anonymous UID; holds no personal identifiers.
//

import Foundation

/// A single answer value. Stored to Firestore as a typed map
/// (`{"type": ..., "value": ...}`) so it round-trips unambiguously
/// (e.g. single vs. text, scale vs. number).
enum BaselineAnswer: Equatable {
    case bool(Bool)
    case single(String)
    case multi([String])
    case scale(Int)
    case number(Double)
    case text(String)

    /// Whether this answer counts as "provided" (used for required validation).
    var isAnswered: Bool {
        switch self {
        case .bool:            return true
        case .scale, .number:  return true
        case .single(let s):   return !s.isEmpty
        case .text(let s):     return !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .multi(let a):    return !a.isEmpty
        }
    }

    /// The value(s) as strings, for evaluating ShowCondition.
    var matchStrings: [String] {
        switch self {
        case .bool(let b):     return [b ? "Yes" : "No"]
        case .single(let s):   return [s]
        case .text(let s):     return [s]
        case .multi(let a):    return a
        case .scale(let i):    return [String(i)]
        case .number(let d):   return [String(d)]
        }
    }

    // MARK: Firestore mapping

    func toFirestore() -> [String: Any] {
        switch self {
        case .bool(let b):   return ["type": "bool", "value": b]
        case .single(let s): return ["type": "single", "value": s]
        case .multi(let a):  return ["type": "multi", "value": a]
        case .scale(let i):  return ["type": "scale", "value": i]
        case .number(let d): return ["type": "number", "value": d]
        case .text(let s):   return ["type": "text", "value": s]
        }
    }

    init?(fromFirestore dict: [String: Any]) {
        guard let type = dict["type"] as? String else { return nil }
        switch type {
        case "bool":   guard let v = dict["value"] as? Bool else { return nil };       self = .bool(v)
        case "single": guard let v = dict["value"] as? String else { return nil };     self = .single(v)
        case "multi":  guard let v = dict["value"] as? [String] else { return nil };   self = .multi(v)
        case "scale":  guard let v = dict["value"] as? Int else { return nil };        self = .scale(v)
        case "number": guard let v = dict["value"] as? Double else { return nil };     self = .number(v)
        case "text":   guard let v = dict["value"] as? String else { return nil };     self = .text(v)
        default: return nil
        }
    }
}

/// A participant's saved answers for one questionnaire.
struct BaselineResponse {
    let uid: String
    let questionnaireID: String
    var answers: [String: BaselineAnswer]   // keyed by question id
    var version: Int
    var completedAt: Date?

    var isCompleted: Bool { completedAt != nil }

    /// Deterministic doc ID: "{uid}_{questionnaireID}".
    static func makeID(uid: String, questionnaireID: String) -> String {
        "\(uid)_\(questionnaireID)"
    }
}
