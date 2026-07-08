//
//  BaselineRepository.swift
//  Chiari Research App
//

import Foundation

protocol BaselineRepository {
    /// All of a participant's saved baseline responses, keyed by questionnaireID.
    func fetchResponses(forUID uid: String) async throws -> [String: BaselineResponse]
    /// Creates or overwrites a questionnaire's response (baseline forms are editable).
    func saveResponse(_ response: BaselineResponse) async throws
}
