//
//  SurveySession.swift
//  Chiari Research App
//

import Foundation

enum SurveySlot: String, Codable, CaseIterable {
    case morning
    case midday
    case afternoon
    case evening

    var hour: Int {
        switch self {
        case .morning: return 8
        case .midday: return 12
        case .afternoon: return 16
        case .evening: return 20
        }
    }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }
}

struct SurveyResponses: Codable, Equatable {
    var hadHeadache: Bool
    var painLevel: Double  // 1–10, only meaningful when hadHeadache == true
    var hadBalanceProblem: Bool = false
    var balance: Double = 0            // 1–10, only meaningful when hadBalanceProblem
    var hadNumbness: Bool = false
    var numbnessTingling: Double = 0   // 1–10, only meaningful when hadNumbness
    // Mood check-ins, each 0–10 (0 = not at all, 10 = very).
    var cheerful: Double = 0
    var sad: Double = 0
    var anxious: Double = 0
}

struct SurveySession: Codable, Identifiable {
    /// Deterministic doc ID: "{userId}_{yyyyMMdd}_{slot.rawValue}"
    let id: String
    let userId: String
    /// Midnight local time on the survey day (stored as UTC Timestamp in Firestore)
    let scheduledDate: Date
    let slot: SurveySlot
    var responses: SurveyResponses?   // nil = not yet completed
    var isCompleted: Bool
    var completedAt: Date?

    static func makeID(userId: String, date: Date, slot: SurveySlot) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd"
        fmt.timeZone = .current
        return "\(userId)_\(fmt.string(from: date))_\(slot.rawValue)"
    }
}
