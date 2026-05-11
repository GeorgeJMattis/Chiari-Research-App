protocol SensorRepository {
    func saveBatch(_batch: SensorBatch) async throws
    func fetchUnsyncedBatches() async throws -> [SensorBatch]
    func markBatchAsSynced(batchID: String) async throws
}