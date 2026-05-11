import Foundation

struct SensorReading: Codable {
    let timestamp: Date
    let value: [String: Double]
}