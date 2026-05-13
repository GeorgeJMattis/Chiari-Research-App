protocol SensorRepository {
    func saveBatch(_ batch: SensorBatch) async throws
    func fetchUnsyncedBatches() async throws -> [SensorBatch]
    func markBatchAsSynced(batchID: String) async throws
    func fetchBatches(forUID uid: String, from: Date, to: Date) async throws -> [SensorBatch]
}
