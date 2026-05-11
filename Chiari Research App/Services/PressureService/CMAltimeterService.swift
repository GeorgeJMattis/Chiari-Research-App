import CoreMotion
import Foundation
import UIKit

@MainActor
class CMAltimeterService: PressureSampling {
    private let altimeter = CMAltimeter()
    private let localRepo = LocalSensorRepository()

    func collectAndSave(uid: String) async throws {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }

        let dataPoints = await nPressureReads()
        guard let dataPoints else { return }

        let batch = SensorBatch(
            id: UUID().uuidString,
            uid: uid,
            sensorType: .pressure,
            startTimeStamp: dataPoints.first?.timestamp,
            endTimeStamp: dataPoints.last?.timestamp,
            readings: dataPoints,
            deviceModel: UIDevice.current.model,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )

        try await localRepo.saveBatch(batch)
    }


    private func nPressureReads() async -> [SensorReading]? {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return nil
        }

        return await withCheckedContinuation { continuation in
            var reads: [SensorReading] = []

            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                guard let data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    self.altimeter.stopRelativeAltitudeUpdates()
                    continuation.resume(returning: nil)
                    return
                }

                let singleRead = SensorReading(
                    timestamp: Date(),
                    value: ["pressure": data.pressure.doubleValue, "altitude": data.relativeAltitude.doubleValue]
                )

                reads.append(singleRead)

                if reads.count >= 10 {
                    self.altimeter.stopRelativeAltitudeUpdates()
                    continuation.resume(returning: reads)
                }
            }
        }
    }
}
