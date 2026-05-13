//
//  UserInfo.swift
//  Chiari Research App
//

import Foundation

struct UserInfo: Codable {
    let uid: String
    var email: String
    var name: String?
    var country: String?
    var state: String?
    var hasCompletedOnboarding: Bool
    var studyStartDate: Date?
    var studyDurationDays: Int

    init(uid: String, email: String, name: String? = nil, country: String? = nil,
         state: String? = nil, hasCompletedOnboarding: Bool,
         studyStartDate: Date? = nil, studyDurationDays: Int = 30) {
        self.uid = uid
        self.email = email
        self.name = name
        self.country = country
        self.state = state
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.studyStartDate = studyStartDate
        self.studyDurationDays = studyDurationDays
    }
}