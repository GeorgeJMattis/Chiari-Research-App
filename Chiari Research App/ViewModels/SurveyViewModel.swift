//
//  SurveyViewModel.swift
//  Chiari Research App
//

import Foundation

@MainActor
class SurveyViewModel: ObservableObject {

    struct SlotStatus: Identifiable {
        let slot: SurveySlot
        let scheduledTime: Date
        var session: SurveySession?

        var id: String { slot.rawValue }
        var isCompleted: Bool { session?.isCompleted == true }
        var isMissed: Bool { !isCompleted && scheduledTime < Date() }
        var isUpcoming: Bool { !isCompleted && scheduledTime > Date() }
    }

    @Published var todaySlots: [SlotStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let surveyRepo = FirebaseSurveyRepository()

    func loadToday(uid: String) async {
        isLoading = true
        defer { isLoading = false }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let sessions: [SurveySession]
        do {
            sessions = try await surveyRepo.fetchSessions(forUID: uid, from: today, to: tomorrow)
        } catch {
            errorMessage = error.localizedDescription
            sessions = []
        }

        let cal = Calendar.current
        todaySlots = SurveySlot.allCases.map { slot in
            let scheduledTime = cal.date(bySettingHour: slot.hour, minute: 0, second: 0, of: Date())!
            let session = sessions.first { $0.slot == slot }
            return SlotStatus(slot: slot, scheduledTime: scheduledTime, session: session)
        }
    }

    /// Fetches yesterday's responses for the same slot to pre-fill the form.
    func fetchPrefill(uid: String, slot: SurveySlot) async -> SurveyResponses? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return try? await surveyRepo.fetchSession(forUID: uid, date: yesterday, slot: slot)?.responses
    }

    func submit(responses: SurveyResponses, uid: String, slot: SurveySlot) async throws {
        let now = Date()
        let session = SurveySession(
            id: SurveySession.makeID(userId: uid, date: now, slot: slot),
            userId: uid,
            scheduledDate: Calendar.current.startOfDay(for: now),
            slot: slot,
            responses: responses,
            isCompleted: true,
            completedAt: now
        )
        try await surveyRepo.saveSurveySession(session)

        if let idx = todaySlots.firstIndex(where: { $0.slot == slot }) {
            todaySlots[idx].session = session
        }
    }
}

