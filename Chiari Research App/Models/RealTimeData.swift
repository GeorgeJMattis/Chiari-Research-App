//
//  RealTimeData.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation

struct RealTimeData: Codable {
    let pressure: Double
    let timestamp: Date
    let relativeAltitudeChange: Double

}
