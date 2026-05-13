//
//  HomeViewModel.swift
//  Chiari Research App
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var participantCount: Int = 0
    @Published var daysRemaining: Int = 30
    @Published var studyDay: Int = 1
    /// Map of calendar-day (midnight) → number of completed surveys (0–4)
    @Published var completionByDay: [Date: Int] = [:]
    @Published var isLoading = false

    private let surveyRepo = FirebaseSurveyRepository()
    private let userRepo   = FirebaseUserRepository()

    func load(uid: String, userInfo: UserInfo) async {
        isLoading = true
        defer { isLoading = false }

        // Study progress
        if let startDate = userInfo.studyStartDate {
            let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
            studyDay      = min(elapsed + 1, userInfo.studyDurationDays)
            daysRemaining = max(0, userInfo.studyDurationDays - elapsed)
        }

        let today = Date()
        let from  = Calendar.current.date(byAdding: .day, value: -30, to: today)!

        do {
            async let sessions = surveyRepo.fetchSessions(forUID: uid, from: from, to: today)
            async let count    = userRepo.fetchParticipantCount()

            let allSessions = try await sessions
            participantCount = (try? await count) ?? 0

            var byDay: [Date: Int] = [:]
            for session in allSessions where session.isCompleted {
                let day = Calendar.current.startOfDay(for: session.scheduledDate)
                byDay[day, default: 0] += 1
            }
            completionByDay = byDay
        } catch {
            // Non-fatal — show empty state
        }
    }
}
