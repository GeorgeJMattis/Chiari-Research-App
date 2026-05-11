import Foundation

struct SensorBatch: Codable {
    let id: String
    let uid: String
    let sensorType: SensorType
    let startTimeStamp: Date?
    let endTimeStamp: Date?
    let readings: [SensorReading]
    var isSynced: Bool = false
    let deviceModel: String?
    let appVersion: String?

}

enum SensorType: String, Codable {
    case pressure
    case humidity
    case light
    case sound
    case electromagneticField
}