//
//  UserInfo.swift
//  Chiari Research App
//

import Foundation

/// Anonymous participant record. Deliberately holds no personal identifiers
/// (no name, email, or location) — only study-tracking fields keyed by the
/// anonymous Firebase UID.
struct UserInfo: Codable {
    let uid: String
    var studyStartDate: Date?
    var studyDurationDays: Int

    init(uid: String, studyStartDate: Date? = nil, studyDurationDays: Int = 30) {
        self.uid = uid
        self.studyStartDate = studyStartDate
        self.studyDurationDays = studyDurationDays
    }
}