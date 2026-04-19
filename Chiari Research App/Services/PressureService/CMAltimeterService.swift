import Foundation
import CoreMotion

class CMAltimeterService: PressureSampling {
    private let altimeter = CMAltimeter()
    private var sessionData: [RealTimeData] = []

    private let realTimeData: RealTimeData
    private let storageService: StorageService
    private let networkService: NetworkService
    
    func startSampling() async {
        sessionData.removeAll()
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
            sessionData.append(sample)
        }
    }
    
    func stopSampling() async {
        altimeter.stopRelativeAltitudeUpdates()
    }
    func getReadings() -> [RealTimeData] {
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