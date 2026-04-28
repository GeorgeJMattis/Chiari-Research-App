//
//  LocalEnvironmentalData.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
import SwiftData
import Foundation


/**
 This data is stored locally and will be sent to firebase on survey completion.
 */
@Model
class LocalPressureData: Codable {
    var pressure: Double
    var timeStamp: Date
    var altitude: Double?
    var flightsClimbed: Int?
    var stepsTaken: Int?
    init(pressure: Double, timeStamp: Date, altitude: Double?, flightsClimbed: Int?, stepsTaken: Int?) {
        self.pressure = pressure //kPa
        self.timeStamp = timeStamp
        self.altitude = altitude //meters
        self.flightsClimbed = flightsClimbed
        self.stepsTaken = stepsTaken
    }
}
