//
//  SensorService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

class SensorService {
    private let pressureService: PressureSampling

    init() {
        #if SENSORKIT_ENABLED
        self.pressureService = SensorKitPressureSampling()
        #else
        self.pressureService = CMAltimeterService()
        #endif
    }

    func collectAndSave(uid: String) async throws {
        try await pressureService.collectAndSave(uid: uid)
    }
}
