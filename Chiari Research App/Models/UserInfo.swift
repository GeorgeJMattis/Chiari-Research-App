//
//  UserInfo.swift
//  Chiari Research App
//

import Foundation

/// Anonymous participant record keyed by the anonymous Firebase UID. Holds no
/// directly identifying information (no name or email). It does record coarse
/// geography (country + region) collected at enrollment, which the study uses
/// for demographic analysis and which the participant can edit later.
struct UserInfo: Codable {
    let uid: String
    var studyStartDate: Date?
    var studyDurationDays: Int
    var country: String?
    /// For the US, one of the 4 Census regions (see Geography.usRegions), not
    /// an exact state — kept coarse to limit re-identification risk. For other
    /// countries, free-text region/province.
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
