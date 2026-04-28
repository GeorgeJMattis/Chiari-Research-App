struct PressureBatch: Codable {
    let batchID: String
    let userID: String
    let timestamp: Date
    let pressureReadings: [PressureData]
}