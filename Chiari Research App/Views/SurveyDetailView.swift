//
//  SurveyDetailView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import SwiftUI

struct SurveyDetailView: View {
    @Environment(\.dismiss) var dismiss
    let survey: SurveySession
    @ObservedObject var surveyViewModel: SurveyViewModel
    @State private var responses: [String: String] = [:]
    
    var body: some View {
        VStack {
            // Survey Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Survey")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(survey.id.uuidString.prefix(8).uppercased())
                    .font(.headline)
                Text("Status: \(survey.isCompleted ? "Completed" : "Pending")")
                    .font(.caption)
                    .foregroundStyle(survey.isCompleted ? .green : .orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
            
            // Survey Questions
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<5, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Question \(index + 1)")
                                .font(.subheadline)
                                .bold()
                            Text("This is a sample survey question?")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField("Your answer", text: Binding(
                                get: { responses["q\(index)"] ?? "" },
                                set: { responses["q\(index)"] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(16)
            }
            
            // Submit Button
            Button(action: {
                Task {
                    await surveyViewModel.submitSurvey(survey)
                    dismiss()
                }
            }) {
                if surveyViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Submit Survey")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 8))
            .padding(16)
            .disabled(surveyViewModel.isLoading || survey.isCompleted)
        }
        .navigationTitle("Survey")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mockSurvey = SurveySession(
        id: UUID(),
        userId: "user1",
        startTime: Date(),
        responses: [:],
        isCompleted: false
    )
    SurveyDetailView(survey: mockSurvey, surveyViewModel: SurveyViewModel())
}
