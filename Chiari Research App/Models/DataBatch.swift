import Foundation

struct PressureBatch: Codable {
    let batchID: String
    let timestamp: Date
    let pressureReadings: [PressureData]
    let isSynced: Bool = false
}
