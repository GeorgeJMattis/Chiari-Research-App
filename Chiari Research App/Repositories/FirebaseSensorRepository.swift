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

    func fetchBatches(forUID uid: String, from: Date, to: Date) async throws -> [SensorBatch] {
        let snapshot = try await db.collection("sensorBatches")
            .whereField("uid", isEqualTo: uid)
            .whereField("startTimeStamp", isGreaterThanOrEqualTo: from)
            .whereField("startTimeStamp", isLessThanOrEqualTo: to)
            .order(by: "startTimeStamp", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { decodeBatch($0) }
    }

    private func decodeBatch(_ doc: QueryDocumentSnapshot) -> SensorBatch? {
        let data = doc.data()
        guard
            let id = data["id"] as? String,
            let uid = data["uid"] as? String,
            let typeRaw = data["sensorType"] as? String,
            let sensorType = SensorType(rawValue: typeRaw)
        else { return nil }

        let startTimeStamp = (data["startTimeStamp"] as? Timestamp)?.dateValue()
        let endTimeStamp   = (data["endTimeStamp"]   as? Timestamp)?.dateValue()
        let deviceModel    = data["deviceModel"] as? String
        let appVersion     = data["appVersion"]  as? String

        let readings: [SensorReading] = (data["readings"] as? [[String: Any]] ?? []).compactMap { r in
            guard
                let ts    = (r["timestamp"] as? Timestamp)?.dateValue(),
                let value = r["value"] as? [String: Double]
            else { return nil }
            return SensorReading(timestamp: ts, value: value)
        }

        return SensorBatch(
            id: id, uid: uid, sensorType: sensorType,
            startTimeStamp: startTimeStamp, endTimeStamp: endTimeStamp,
            readings: readings, isSynced: true,
            deviceModel: deviceModel, appVersion: appVersion
        )
    }
}