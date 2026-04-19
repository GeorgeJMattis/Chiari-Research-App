import Foundation
import CoreMotion

class CMAltimeterService: PressureSampling {
    private let motionManager = CMMotionManager()
    
    func startSampling() async {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }
        
        motionManager.relativeAltitudeUpdateInterval = 1.0
        motionManager.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let pressure = data.pressure.doubleValue // Pressure in kPa
            let relativeAltitudeChange = data.relativeAltitude.doubleValue // Relative altitude change in meters
            let timeStamp = Date()
            
            // TODO: Store or publish this data to your app
            print("Pressure: \(pressure) kPa, Altitude: \(relativeAltitudeChange)m")
        }
    }
    
    func stopSampling() async {
        motionManager.stopRelativeAltitudeUpdates()
    }
    
    func singleRead() async {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }
        
        // TODO: Implement single read - start updates, get one reading, then stop
    }
}