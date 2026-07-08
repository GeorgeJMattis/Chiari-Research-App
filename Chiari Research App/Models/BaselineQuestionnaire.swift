//
//  BaselineQuestionnaire.swift
//  Chiari Research App
//
//  Schema for the data-driven baseline questionnaires. Questionnaires are
//  defined as data (see BaselineCatalog) and rendered generically by
//  BaselineFormView — there is one renderer for every form.
//

import Foundation

/// A single baseline questionnaire (e.g. "Symptoms"), made of ordered questions.
struct BaselineQuestionnaire: Identifiable {
    let id: String          // stable key, e.g. "symptoms"
    let title: String       // "Symptoms"
    let subtitle: String    // short blurb / estimated time
    let systemImage: String // SF Symbol for the list row
    let version: Int        // bump when the questions change
    let questions: [BaselineQuestion]
}

/// One question within a questionnaire.
struct BaselineQuestion: Identifiable {
    let id: String
    let prompt: String
    let type: QuestionType
    var isOptional: Bool = false
    /// When set, the question is only shown if the condition is satisfied.
    var condition: ShowCondition? = nil
}

/// The kind of answer a question expects, plus the options/bounds it needs.
enum QuestionType {
    case boolean
    case singleChoice([String])
    case multiChoice([String])                                   // "check all that apply"
    case scale(min: Int, max: Int, minLabel: String, maxLabel: String)
    case number(min: Double, max: Double, unit: String?)         // e.g. age, height
    case text
}

/// Conditional display: show the owning question only when the answer to
/// `questionID` matches one of `equals`. Works against boolean and single/multi
/// choice answers.
struct ShowCondition {
    let questionID: String
    let equals: [String]
}
