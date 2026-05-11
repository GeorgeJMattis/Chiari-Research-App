protocol SensorRepository {
    func saveBatch(_ batch: SensorBatch) async throws
    func fetchUnsyncedBatches() async throws -> [SensorBatch]
    func markBatchAsSynced(batchID: String) async throws
}
