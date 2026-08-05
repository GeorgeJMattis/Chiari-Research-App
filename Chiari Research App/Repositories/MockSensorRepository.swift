//
//  MockSensorRepository.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for FirebaseSensorRepository.
//

import Foundation

class MockSensorRepository: SensorRepository {
    func saveBatch(_ batch: SensorBatch) async throws {}
    func fetchUnsyncedBatches() async throws -> [SensorBatch] { [] }
    func markBatchAsSynced(batchID: String) async throws {}

    func fetchBatches(forUID uid: String, from: Date, to: Date) async throws -> [SensorBatch] {
        MockDataGenerator.sensorBatches(uid: uid, from: from, to: to)
    }
}
