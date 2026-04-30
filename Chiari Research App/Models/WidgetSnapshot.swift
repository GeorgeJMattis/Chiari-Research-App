//
//  WidgetSnapshot.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

import Foundation

struct WidgetSnapshot: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let endTime: Date?
    let pressureReadings: [PressureData]
}
