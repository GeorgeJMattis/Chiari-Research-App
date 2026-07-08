//
//  UserInfo.swift
//  Chiari Research App
//

import Foundation

/// Anonymous participant record keyed by the anonymous Firebase UID. Holds no
/// directly identifying information (no name or email). It does record coarse
/// geography (country + state/region) collected at enrollment, which the study
/// uses for demographic analysis and which the participant can edit later.
struct UserInfo: Codable {
    let uid: String
    var studyStartDate: Date?
    var studyDurationDays: Int
    var country: String?
    var stateRegion: String?

    init(uid: String,
         studyStartDate: Date? = nil,
         studyDurationDays: Int = 30,
         country: String? = nil,
         stateRegion: String? = nil) {
        self.uid = uid
        self.studyStartDate = studyStartDate
        self.studyDurationDays = studyDurationDays
        self.country = country
        self.stateRegion = stateRegion
    }
}
