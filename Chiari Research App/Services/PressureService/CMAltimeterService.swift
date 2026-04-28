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
                let dataPoint = await self.singlePressureRead()
                if let dataPoint = dataPoint {
                    if self.sessionData.count >= 10 {
                        self.savePressureData(self.sessionData)
                        self.sessionData.removeAll()
                    }
                    self.sessionData.append(dataPoint)
                }
            }
        }
    }

    func singlePressureRead() async -> PressureData? {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return nil
        }
        
        return await withCheckedContinuation { continuation in
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
                
                self?.altimeter.stopRelativeAltitudeUpdates()
                continuation.resume(returning: singleRead)
            }
        }
    }


    /*

        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let sample = RealTimeData(pressure: data.pressure.doubleValue, timestamp: Date(), relativeAltitudeChange: data.relativeAltitude.doubleValue)
            
            if sessionData.count >= 100 {
                savePressureData(sessionData)
                sessionData.removeAll
            }

            sessionData.append(sample)
        }
    }
    
    func stopSampling() async {
        timer?.invalidate()
        timer = nil
        savePressureData(sessionData)
    }
    
    func getReadings() -> [PressureData] {
        return sessionData
    }
    func singleRead() async {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }
        
        // TODO: Implement single read - start updates, get one reading, then stop
    }
}