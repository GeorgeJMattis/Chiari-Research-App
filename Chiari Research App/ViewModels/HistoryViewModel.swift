//
//  HistoryViewModel.swift
//  Chiari Research App
//

import Foundation

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

    private let surveyRepo = FirebaseSurveyRepository()
    private let sensorRepo = FirebaseSensorRepository()

    func load(uid: String) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        let to   = Date()
        let from = Calendar.current.date(byAdding: .day, value: -range.days, to: to)!

        do {
            async let sessions = surveyRepo.fetchSessions(forUID: uid, from: from, to: to)
            async let batches  = sensorRepo.fetchBatches(forUID: uid, from: from, to: to)
            surveySessions = try await sessions
            sensorBatches  = try await batches
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
