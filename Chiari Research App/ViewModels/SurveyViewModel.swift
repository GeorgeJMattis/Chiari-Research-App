//
//  SurveyViewModel.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import Foundation
import Combine

@MainActor
class SurveyViewModel: ObservableObject {
    @Published var surveys: [SurveySession] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init() {
        // TODO: Load surveys from repository/service
        loadMockSurveys()
    }
    
    private func loadMockSurveys() {
        // Mock data for now
        surveys = [
            SurveySession(id: UUID(), userId: "user1", startTime: Date(), responses: [:], isCompleted: false),
            SurveySession(id: UUID(), userId: "user1", startTime: Date().addingTimeInterval(-86400), responses: [:], isCompleted: true),
        ]
    }
    
    func submitSurvey(_ survey: SurveySession) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Integrate with SurveySessionManager
            try await Task.sleep(nanoseconds: 500_000_000)
            // Simulate success
            isLoading = false
        } catch {
            errorMessage = "Failed to submit survey"
            isLoading = false
        }
    }
}
