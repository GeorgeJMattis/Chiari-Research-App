//
//  HomeView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var surveyViewModel: SurveyViewModel
    @State private var selectedSurvey: SurveySession?
    @State private var showSurveyDetail = false
    @State private var userInfo: UserInfo?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(userInfo?.name ?? "User")")
                        .font(.title2)
                        .bold()
                    Text("Continue with your surveys")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
                
                // Survey List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Surveys")
                        .font(.headline)
                    
                    if surveyViewModel.surveys.isEmpty {
                        Text("No surveys available")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(20)
                    } else {
                        ForEach(surveyViewModel.surveys, id: \.id) { survey in
                            NavigationLink(destination: SurveyDetailView(survey: survey, surveyViewModel: surveyViewModel)) {
                                SurveyRowView(survey: survey)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding(16)
            .navigationTitle("Home")
            .onAppear {
                fetchUserInfo()
            }
        }
    }
    
    func fetchUserInfo() {
        guard let uid = authViewModel.currentUser else { return }
        
        let userRepository: UserRepository = LocalUserRepository()
        
        Task {
            do {
                let fetchedUser = try await userRepository.fetchUser(uid: uid)
                await MainActor.run {
                    userInfo = fetchedUser
                }
            } catch {
                print("Error fetching user: \(error)")
            }
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
        .padding(12)
        .background(.white)
        .border(.gray.opacity(0.2), width: 1)
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel(), surveyViewModel: SurveyViewModel())
}
