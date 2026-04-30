//
//  SurveySession.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation

struct SurveySession: Codable, Identifiable {
    let id: UUID
    let userId: String
    let startTime: Date
    var responses: [String: String]
    var isCompleted: Bool
}
