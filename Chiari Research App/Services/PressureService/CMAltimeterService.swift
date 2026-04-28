import Foundation
import CoreMotion

class CMAltimeterService: PressureSampling {
    private let altimeter = CMAltimeter()
    private var sessionData: [PressureData] = []
    var timer: Timer?

    
    func startSampling() async {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                guard let self = self else { return }
                let ndataPoints = await self.nPressureReads()
                if let ndataPoints = ndataPoints {
                    if self.sessionData.count >= 10 {
                        self.savePressureData(self.sessionData)
                        self.sessionData.removeAll()
                    }
                    self.sessionData.append(contentsOf: ndataPoints)
                }
            }
        }
    }

    func nPressureReads() async -> [PressureData]? {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            var nReads: [PressureData] = []
            self.altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    self?.altimeter.stopRelativeAltitudeUpdates()
                    continuation.resume(returning: nil)
                    return
                }
            
                let singleRead = PressureData(
                    pressure: data.pressure.doubleValue,
                    timestamp: Date(),
                    relativeAltitudeChange: data.relativeAltitude.doubleValue
                )
                nReads.append(singleRead)
                if nReads.count >= 5 {
                    self?.altimeter.stopRelativeAltitudeUpdates()
                    continuation.resume(returning: nReads)
                }
            }
        }
    }


    
    func stopSampling() async {
        timer?.invalidate()
        timer = nil
        savePressureDataToDisk(sessionData)
    }
    
    func getReadings() -> [PressureData] {
        return sessionData
    }
}