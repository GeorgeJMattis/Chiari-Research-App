//
//  PressureData.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation

struct PressureData: Codable {
    let pressure: Double
    let timeStamp: Date
    let altitude: Double?
    let flightsClimbed: Int?
    let stepsTaken: Int?
}
