//
//  WidgetSnapshot.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation
import SwiftData

/**
 This data is collected in real time during the survey session and stored locally until survey completion, at which point it will be sent to firebase.
 */
@Model
class WidgetSnapshot {
    var id: String
    var timestamp: Date
    var endTime: Date?
    var realTimeData: [RealTimeData]
}