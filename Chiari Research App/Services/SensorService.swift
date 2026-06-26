//
//  SensorService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/18/26.
//

class SensorService {
    private let pressureService: PressureSampling

    init() {
        // Live barometric pressure always comes from CMAltimeter. SensorKit is
        // a separate, fetch-based source (SensorKitManager) that runs alongside
        // this rather than replacing it, because SensorKit data is delayed 24h.
        self.pressureService = CMAltimeterService()
    }

    func collectAndSave(uid: String) async throws {
        try await pressureService.collectAndSave(uid: uid)
    }
}
