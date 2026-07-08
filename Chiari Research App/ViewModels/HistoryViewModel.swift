//
//  HistoryViewModel.swift
//  Chiari Research App
//

import Foundation
import Combine

@MainActor
class HistoryViewModel: ObservableObject {

    enum Range: String, CaseIterable {
        case week  = "7 Days"
        case month = "30 Days"

        var days: Int {
            switch self {
            case .week:  return 7
            case .month: return 30
            }
        }
    }

    @Published var surveySessions: [SurveySession] = []
    @Published var sensorBatches: [SensorBatch] = []
    @Published var range: Range = .week
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// While real sensor access (SensorKit) is unavailable, populate the history
    /// charts with synthesized data so the UI can be developed and demoed.
    /// Flip to `false` once real sensor + survey data is flowing.
    var useMockData = true

    private let surveyRepo = FirebaseSurveyRepository()
    private let sensorRepo = FirebaseSensorRepository()

    func load(uid: String) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        let to   = Date()
        let from = Calendar.current.date(byAdding: .day, value: -range.days, to: to)!

        if useMockData {
            let mock = makeMockData(uid: uid, from: from, to: to)
            sensorBatches  = mock.batches
            surveySessions = mock.sessions
            return
        }

        do {
            async let sessions = surveyRepo.fetchSessions(forUID: uid, from: from, to: to)
            async let batches  = sensorRepo.fetchBatches(forUID: uid, from: from, to: to)
            surveySessions = try await sessions
            sensorBatches  = try await batches
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Mock data

    /// Builds one pressure batch per day plus a headache check-in on some days,
    /// spanning [from, to]. Pressure gently oscillates around ~1013 hPa; pain
    /// levels vary so the overlay chart shows movement.
    private func makeMockData(uid: String, from: Date, to: Date) -> (batches: [SensorBatch], sessions: [SurveySession]) {
        let cal = Calendar.current
        let dayCount = max(1, (cal.dateComponents([.day], from: from, to: to).day ?? range.days))

        var batches: [SensorBatch] = []
        var sessions: [SurveySession] = []

        for offset in 0...dayCount {
            guard let day = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: from)) else { continue }

            // A few pressure readings across the day.
            var readings: [SensorReading] = []
            for hour in stride(from: 8, through: 20, by: 4) {
                guard let ts = cal.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }
                // Base ~1013 hPa with a daily wave and an hourly wobble.
                let wave = sin(Double(offset) / 3.0) * 6.0
                let wobble = Double((hour / 4) % 3) * 1.5
                let pressure = 1013.0 + wave + wobble
                readings.append(SensorReading(timestamp: ts, value: ["pressure": pressure]))
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

            // Headache on roughly every other day, pain tracking the pressure wave.
            if offset % 2 == 0 {
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
        }

        return (batches, sessions)
    }
}
