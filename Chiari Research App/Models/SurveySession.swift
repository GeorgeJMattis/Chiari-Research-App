//
//  SurveySession.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation
import SwiftData

/**
    This model represents a survey session, which includes the survey date, start and end times, and the collected local pressure data and real-time data. The local pressure data is stored locally and will be sent to firebase on survey completion, while the real-time data is collected during the survey session and stored locally until survey completion, at which point it will also be sent to firebase.
*/
@Model
class SurveySession {
    var id: String
    var surveyDate: Date
    var surveyStartTime: Date
    var surveyEndTime: Date?
    var localPressureData: [LocalPressureData]
}
