//
//  BaselineViewModel.swift
//  Chiari Research App
//
//  Drives the baseline questionnaires: loads saved responses, exposes
//  completion counts (for the list + the Home reminder), and saves submissions.
//  Shared between BaselineView and HomeView via TabBarView.
//

import Foundation
import Combine

@MainActor
class BaselineViewModel: ObservableObject {
    let questionnaires = BaselineCatalog.all

    /// Saved responses keyed by questionnaireID.
    @Published var responses: [String: BaselineResponse] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repo: BaselineRepository = FirebaseBaselineRepository()
    private var hasLoaded = false

    var totalCount: Int { questionnaires.count }

    var completedCount: Int {
        questionnaires.filter { isCompleted($0.id) }.count
    }

    var allCompleted: Bool { completedCount == totalCount && totalCount > 0 }

    func isCompleted(_ questionnaireID: String) -> Bool {
        responses[questionnaireID]?.isCompleted ?? false
    }

    func response(for questionnaireID: String) -> BaselineResponse? {
        responses[questionnaireID]
    }

    /// Loads once per session unless `force` is set (e.g. pull-to-refresh).
    func load(uid: String, force: Bool = false) async {
        guard !uid.isEmpty, force || !hasLoaded else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            responses = try await repo.fetchResponses(forUID: uid)
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submit(questionnaireID: String, answers: [String: BaselineAnswer], uid: String) async {
        let questionnaire = BaselineCatalog.questionnaire(id: questionnaireID)
        let response = BaselineResponse(
            uid: uid,
            questionnaireID: questionnaireID,
            answers: answers,
            version: questionnaire?.version ?? 1,
            completedAt: Date()
        )
        do {
            try await repo.saveResponse(response)
            responses[questionnaireID] = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
