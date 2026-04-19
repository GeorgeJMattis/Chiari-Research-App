//
//  RealTimeData.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation

/**
 This data is collected in real time during the survey session and stored locally until survey completion, at which point it will be sent to firebase.
 */
struct RealTimeData: Codable {
    let id: String = UUID().uuidString
    var timestamp: Date
    let realTimePressure: Double
    let realTimeAudioLevel: Double?
    let realTimeScreenBrightness: Double
    let relativeAltitudeChange: Double


    
}
