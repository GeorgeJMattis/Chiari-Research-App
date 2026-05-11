import Foundation
import FirebaseFirestore

class FirebaseSensorRepository: SensorRepository {
    private let db = Firestore.firestore()

    func saveBatch(_ batch: SensorBatch) async throws {
        let data: [String: Any] = [
            "id": batch.id,
            "uid": batch.uid,
            "sensorType": batch.sensorType.rawValue,
            "startTimeStamp": batch.startTimeStamp as Any,
            "endTimeStamp": batch.endTimeStamp as Any,
            "readings": batch.readings.map { [
                "timestamp": $0.timestamp,
                "value": $0.value
            ] as [String: Any] },
            "isSynced": batch.isSynced,
            "deviceModel": batch.deviceModel as Any,
            "appVersion": batch.appVersion as Any
        ]
        try await db.collection("sensorBatches").document(batch.id).setData(data)
    }

    func fetchUnsyncedBatches() async throws -> [SensorBatch] {
        throw NSError(domain: "FirebaseSensorRepository", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Use LocalSensorRepository to fetch unsynced batches"
        ])
    }

    func markBatchAsSynced(batchID: String) async throws {
        throw NSError(domain: "FirebaseSensorRepository", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Use LocalSensorRepository to mark batches as synced"
        ])
    }
}