//
//  SurveyView.swift
//  Chiari Research App
//

import SwiftUI

struct SurveyView: View {
    @ObservedObject var surveyViewModel: SurveyViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Surveys View")
                    .font(.title)
                Text("\(surveyViewModel.surveys.count) surveys available")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Surveys")
        }
    }
}

#Preview {
    SurveyView(surveyViewModel: SurveyViewModel())
}
