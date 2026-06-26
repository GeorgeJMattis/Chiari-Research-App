//
//  SensorKitManager.swift
//  Chiari Research App
//
//  Fetch-based SensorKit collection for ambient pressure + ambient light.
//
//  SensorKit works very differently from CMAltimeter:
//    1. You request authorization once (system prompt, per sensor).
//    2. You call startRecording() so the OS begins persisting samples.
//    3. Recorded data is held under a 24h privacy embargo, then becomes
//       readable via a fetch request. So this is a "record now, fetch later"
//       model, not a live read. We fetch everything new each time the app
//       becomes active and store it as SensorBatches (same pipeline as
//       CMAltimeter), so the existing local-save + Firebase-sync flow is reused.
//
//  This whole file only compiles when the SENSORKIT_ENABLED build flag is set,
//  which should only be turned on once the Apple SensorKit reader entitlement
//  (com.apple.developer.sensorkit.reader.allow) is in the provisioning profile.
//  SensorKit returns no data and does not run in the simulator without it.
//
//  NOTE: A handful of SensorKit API details (marked "VERIFY") cannot be
//  compiled/tested on this machine. Confirm them in Xcode against the SDK the
//  first time you build with SENSORKIT_ENABLED on a Mac.
//

#if SENSORKIT_ENABLED
import Foundation
import SensorKit
import UIKit

final class SensorKitManager: NSObject {
    static let shared = SensorKitManager()

    /// Sensors this app collects. Add/remove here to change coverage.
    private let sensors: [SRSensor] = [.ambientPressure, .ambientLightSensor]

    private lazy var readers: [SRSensor: SRSensorReader] = {
        var dict: [SRSensor: SRSensorReader] = [:]
        for sensor in sensors {
            let reader = SRSensorReader(sensor: sensor)
            reader.delegate = self
            dict[sensor] = reader
        }
        return dict
    }()

    private let localRepo = LocalSensorRepository()

    /// uid for the in-flight fetch session.
    private var currentUID: String?
    /// Samples accumulated per sensor for the current fetch, flushed to a
    /// SensorBatch on didCompleteFetch.
    private var accumulators: [SRSensor: [SensorReading]] = [:]

    private override init() { super.init() }

    // MARK: - Entry point (call when the app becomes active and a user is signed in)

    /// Request authorization (if needed), start recording, and fetch any
    /// newly-available data. Safe to call repeatedly — the auth prompt only
    /// shows once and recording start is idempotent.
    func activateAndFetch(uid: String) {
        currentUID = uid
        SRSensorReader.requestAuthorization(sensors: Set(sensors)) { [weak self] error in
            guard let self else { return }
            if let error {
                print("SensorKit authorization error: \(error.localizedDescription)")
                return
            }
            self.startRecordingForAuthorizedSensors()
            self.fetchAllAvailable(uid: uid)
        }
    }

    private func startRecordingForAuthorizedSensors() {
        for (sensor, reader) in readers {
            guard reader.authorizationStatus == .authorized else {
                print("SensorKit \(sensor.rawValue) not authorized (\(reader.authorizationStatus.rawValue))")
                continue
            }
            reader.startRecording()
        }
    }

    /// Kicks off a fetch on each authorized reader. fetchDevices() triggers the
    /// didFetch(devices:) delegate, where we issue the actual SRFetchRequest.
    private func fetchAllAvailable(uid: String) {
        currentUID = uid
        for (sensor, reader) in readers where reader.authorizationStatus == .authorized {
            accumulators[sensor] = []
            reader.fetchDevices()
        }
    }

    // MARK: - Watermark (so each fetch only pulls data newer than last time)

    private func watermarkKey(for sensor: SRSensor) -> String {
        "sensorkit_watermark_\(sensor.rawValue)"
    }

    private func fromAbsoluteTime(for sensor: SRSensor) -> SRAbsoluteTime {
        let stored = UserDefaults.standard.double(forKey: watermarkKey(for: sensor))
        if stored > 0 {
            return SRAbsoluteTime.fromCFAbsoluteTime(stored)
        }
        // First run: reach back a week. SensorKit only returns data older than
        // the 24h embargo regardless of how far back we ask.
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        return SRAbsoluteTime.fromCFAbsoluteTime(weekAgo.timeIntervalSinceReferenceDate)
    }

    private func setWatermark(_ date: Date, for sensor: SRSensor) {
        UserDefaults.standard.set(date.timeIntervalSinceReferenceDate, forKey: watermarkKey(for: sensor))
    }

    private func sensorType(for sensor: SRSensor) -> SensorType {
        sensor == .ambientPressure ? .pressure : .light
    }
}

// MARK: - SRSensorReaderDelegate

extension SensorKitManager: SRSensorReaderDelegate {

    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
        print("SensorKit \(reader.sensor.rawValue) authorization changed: \(authorizationStatus.rawValue)")
    }

    /// Devices available for this sensor (this iPhone, and any paired watch).
    /// Issue a fetch per device for the new time window.
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        let sensor = reader.sensor
        let request = SRFetchRequest()
        request.from = fromAbsoluteTime(for: sensor)
        request.to = SRAbsoluteTime.fromCFAbsoluteTime(Date().timeIntervalSinceReferenceDate)

        guard !devices.isEmpty else {
            print("SensorKit \(sensor.rawValue): no devices to fetch")
            return
        }
        for device in devices {
            request.device = device
            reader.fetch(request)
        }
    }

    /// Called once per sample. Return true to keep receiving results.
    /// VERIFY: property accessor is `result.sample` on current SDKs (older
    /// samples used `result.sampleObject`).
    func sensorReader(_ reader: SRSensorReader,
                      fetching fetchRequest: SRFetchRequest,
                      didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        let date = Date(timeIntervalSinceReferenceDate: result.timestamp.toCFAbsoluteTime())

        switch result.sample {
        case let pressure as SRAmbientPressureSample:
            // VERIFY: property names pressure/temperature as Measurement values.
            let reading = SensorReading(timestamp: date, value: [
                "pressure": pressure.pressure.converted(to: .hectopascals).value,
                "temperature": pressure.temperature.converted(to: .celsius).value
            ])
            accumulators[reader.sensor, default: []].append(reading)

        case let light as SRAmbientLightSample:
            // VERIFY: `lux` is a Measurement<UnitIlluminance>; chromaticity is
            // available as light.chromaticity.x / .y if you want it later.
            let reading = SensorReading(timestamp: date, value: [
                "lux": light.lux.converted(to: .lux).value
            ])
            accumulators[reader.sensor, default: []].append(reading)

        default:
            print("SensorKit: unhandled sample type \(type(of: result.sample))")
        }
        return true
    }

    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        let sensor = reader.sensor
        let readings = accumulators[sensor] ?? []
        accumulators[sensor] = []

        guard let uid = currentUID, !readings.isEmpty else { return }

        let sorted = readings.sorted { $0.timestamp < $1.timestamp }
        let batch = SensorBatch(
            id: UUID().uuidString,
            uid: uid,
            sensorType: sensorType(for: sensor),
            startTimeStamp: sorted.first?.timestamp,
            endTimeStamp: sorted.last?.timestamp,
            readings: sorted,
            deviceModel: UIDevice.current.model,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )

        if let last = sorted.last?.timestamp {
            setWatermark(last, for: sensor)
        }

        Task {
            do {
                try await localRepo.saveBatch(batch)
                print("SensorKit: saved \(sorted.count) \(sensor.rawValue) reading(s) as batch \(batch.id)")
            } catch {
                print("SensorKit: failed to save batch: \(error.localizedDescription)")
            }
        }
    }

    func sensorReader(_ reader: SRSensorReader,
                      fetching fetchRequest: SRFetchRequest,
                      failedWithError error: Error) {
        print("SensorKit \(reader.sensor.rawValue) fetch failed: \(error.localizedDescription)")
    }

    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        print("SensorKit \(reader.sensor.rawValue) startRecording failed: \(error.localizedDescription)")
    }

    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
        print("SensorKit \(reader.sensor.rawValue) stopRecording failed: \(error.localizedDescription)")
    }
}
#endif
