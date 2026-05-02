import CoreMotion
import Foundation

@MainActor
class CMAltimeterService: PressureSampling {
    private let altimeter = CMAltimeter()
    private let storageService = StorageService()
    private var sessionData: [PressureData] = []
    private var timer: Timer?

    func startSampling() async {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self else { return }

            Task {
                let dataPoints = await self.nPressureReads()
                guard let dataPoints else { return }

                self.sessionData.append(contentsOf: dataPoints)

                if self.sessionData.count >= 10 {
                    self.storageService.savePressureDataToDisk(self.sessionData)
                    self.sessionData.removeAll()
                }
            }
        }
    }

    func stopSampling() async {
        timer?.invalidate()
        timer = nil

        altimeter.stopRelativeAltitudeUpdates()

        if !sessionData.isEmpty {
            storageService.savePressureDataToDisk(sessionData)
            sessionData.removeAll()
        }
    }

    func singleRead() async {
        _ = await nPressureReads()
    }

    private func nPressureReads() async -> [PressureData]? {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return nil
        }

        return await withCheckedContinuation { continuation in
            var reads: [PressureData] = []

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

                let singleRead = PressureData(
                    pressure: data.pressure.doubleValue,
                    timeStamp: Date(),
                    altitude: data.relativeAltitude.doubleValue,
                    flightsClimbed: nil,
                    stepsTaken: nil
                )

                reads.append(singleRead)

                if reads.count >= 20 {
                    self.altimeter.stopRelativeAltitudeUpdates()
                    continuation.resume(returning: reads)
                }
            }
        }
    }
}
