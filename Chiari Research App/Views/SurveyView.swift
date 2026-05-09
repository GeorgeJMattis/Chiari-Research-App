//
//  SurveyView.swift
//  Chiari Research App
//

import SwiftUI

struct SurveyView: View {
    @ObservedObject var surveyViewModel: SurveyViewModel

    var body: some View {
        NavigationStack {
            Group {
                if surveyViewModel.surveys.isEmpty {
                    VStack {
                        Spacer()
                        Text("No surveys available")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    List(surveyViewModel.surveys) { survey in
                        NavigationLink(destination: SurveyDetailView(survey: survey, surveyViewModel: surveyViewModel)) {
                            SurveyRowView(survey: survey)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Surveys")
        }
    }
}

struct SurveyRowView: View {
    let survey: SurveySession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Survey")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(survey.id.uuidString.prefix(8).uppercased())
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(survey.isCompleted ? "Completed" : "Pending")
                        .font(.caption)
                        .foregroundStyle(survey.isCompleted ? .green : .orange)
                    Text(survey.timeStamp.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SurveyView(surveyViewModel: SurveyViewModel())
}
