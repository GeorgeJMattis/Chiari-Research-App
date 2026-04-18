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
class LocalPressureData {
    var pressure: Double
    var timeStamp: Date
    var relativeAltitudeChange: Double
    init(pressure: Double, timeStamp: Date, relativeAltitudeChange: Double) {
        self.pressure = pressure //kPa
        self.timeStamp = timeStamp
        self.relativeAltitudeChange = relativeAltitudeChange //meters
    }
}
