//
//  MockBaselineRepository.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for FirebaseBaselineRepository. No-op, no saved
//  responses — the baseline forms render empty/unanswered in the preview.
//

import Foundation

class MockBaselineRepository: BaselineRepository {
    func fetchResponses(forUID uid: String) async throws -> [String: BaselineResponse] { [:] }
    func saveResponse(_ response: BaselineResponse) async throws {}
}
