import Foundation

class LocalSensorRepository: SensorRepository {
    private let batchesDirectory: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("sensor_batches")
    }()

    func saveBatch(_ batch: SensorBatch) async throws{
        try FileManager.default.createDirectory(at: batchesDirectory, withIntermediateDirectories: true)
        let fileURL = batchesDirectory.appendingPathComponent("\(batch.id).json")
        let data = try JSONEncoder().encode(batch)
        try data.write(to: fileURL)

    }

    func fetchUnsyncedBatches() async throws -> [SensorBatch] {
        guard FileManager.default.fileExists(atPath: batchesDirectory.path) else {
            return []
        }

        let urls = try FileManager.default.contentsOfDirectory(
            at: batchesDirectory,
            includingPropertiesForKeys: nil
        )

        let decoder = JSONDecoder()
        var batches: [SensorBatch] = []

        for url in urls where url.pathExtension == "json" {
            do {
                let data = try Data(contentsOf: url)
                let batch = try decoder.decode(SensorBatch.self, from: data)
                if !batch.isSynced {
                    batches.append(batch)
                }
            } catch {
                // Skip corrupted files rather than failing the whole fetch
                print("Skipping unreadable batch file \(url.lastPathComponent): \(error)")
            }
        }

        return batches
    }

    func markBatchAsSynced(batchID: String) async throws {
        let fileURL = batchesDirectory.appendingPathComponent("\(batchID).json")
        let data = try Data(contentsOf: fileURL)
        var batch = try JSONDecoder().decode(SensorBatch.self, from: data)
        batch.isSynced = true
        let updatedData = try JSONEncoder().encode(batch)
        try updatedData.write(to: fileURL)
    }

    func fetchBatches(forUID uid: String, from: Date, to: Date) async throws -> [SensorBatch] {
        throw NSError(domain: "LocalSensorRepository", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Use FirebaseSensorRepository to fetch batches for history"
        ])
    }

}