//
//  MockDataGenerator.swift
//  Chiari Research App
//
//  Shared synthetic-data generator used by the UI_ONLY_BETA mock repositories.
//  Produces a pressure batch per day plus a headache check-in on alternating
//  days, spanning [from, to], so Home/History charts render populated,
//  plausible-looking sample data with no network access.
//

import Foundation

enum MockDataGenerator {
    static func sensorBatches(uid: String, from: Date, to: Date) -> [SensorBatch] {
        let cal = Calendar.current
        let dayCount = max(1, cal.dateComponents([.day], from: from, to: to).day ?? 0)

        var batches: [SensorBatch] = []
        for offset in 0...dayCount {
            guard let day = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: from)) else { continue }

            var readings: [SensorReading] = []
            for hour in stride(from: 8, through: 20, by: 4) {
                guard let ts = cal.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }
                let wave = sin(Double(offset) / 3.0) * 6.0
                let wobble = Double((hour / 4) % 3) * 1.5
                readings.append(SensorReading(timestamp: ts, value: ["pressure": 1013.0 + wave + wobble]))
            }

            batches.append(
                SensorBatch(
                    id: "mock_\(uid)_\(offset)",
                    uid: uid,
                    sensorType: .pressure,
                    startTimeStamp: readings.first?.timestamp ?? day,
                    endTimeStamp: readings.last?.timestamp ?? day,
                    readings: readings,
                    isSynced: true,
                    deviceModel: "Mock",
                    appVersion: "mock"
                )
            )
        }
        return batches
    }

    static func surveySessions(uid: String, from: Date, to: Date) -> [SurveySession] {
        let cal = Calendar.current
        let dayCount = max(1, cal.dateComponents([.day], from: from, to: to).day ?? 0)

        var sessions: [SurveySession] = []
        for offset in 0...dayCount where offset % 2 == 0 {
            guard let day = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: from)) else { continue }
            let pain = min(10.0, max(1.0, 5.0 + sin(Double(offset) / 3.0) * 3.0))
            let scheduled = cal.date(bySettingHour: 20, minute: 0, second: 0, of: day) ?? day
            sessions.append(
                SurveySession(
                    id: SurveySession.makeID(userId: uid, date: day, slot: .evening),
                    userId: uid,
                    scheduledDate: scheduled,
                    slot: .evening,
                    responses: SurveyResponses(hadHeadache: true, painLevel: pain.rounded()),
                    isCompleted: true,
                    completedAt: scheduled
                )
            )
        }
        return sessions
    }
}
