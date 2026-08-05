//
//  MockSurveyRepository.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for FirebaseSurveyRepository.
//

import Foundation

class MockSurveyRepository: SurveyRepository {
    func saveSurveySession(_ session: SurveySession) async throws {}

    func fetchSessions(forUID uid: String, from: Date, to: Date) async throws -> [SurveySession] {
        MockDataGenerator.surveySessions(uid: uid, from: from, to: to)
    }

    func fetchSession(forUID uid: String, date: Date, slot: SurveySlot) async throws -> SurveySession? {
        MockDataGenerator.surveySessions(uid: uid, from: date, to: date).first { $0.slot == slot }
    }
}
