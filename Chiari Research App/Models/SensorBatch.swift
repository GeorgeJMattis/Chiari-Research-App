import Foundation

struct SensorBatch: Codable {
    let id: String
    let uid: String
    let sensorType: SensorType
    let startTimeStamp: Date?
    let endTimeStamp: Date?
    let readings: [SensorReading]
    var isSynced: Bool
    let deviceModel: String?
    let appVersion: String?

    init(id: String, uid: String, sensorType: SensorType, startTimeStamp: Date?, endTimeStamp: Date?, readings: [SensorReading], isSynced: Bool = false, deviceModel: String?, appVersion: String?) {
        self.id = id
        self.uid = uid
        self.sensorType = sensorType
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.readings = readings
        self.isSynced = isSynced
        self.deviceModel = deviceModel
        self.appVersion = appVersion
    }
}

enum SensorType: String, Codable {
    case pressure
    case humidity
    case light
    case sound
    case electromagneticField
}