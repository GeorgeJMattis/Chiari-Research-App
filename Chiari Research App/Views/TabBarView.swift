//
//  TabBarView.swift
//  Chiari Research App
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    @ObservedObject var authViewModel: AuthViewModel

    @StateObject private var surveyViewModel  = SurveyViewModel()
    @StateObject private var homeViewModel    = HomeViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()

    enum Tab: Int {
        case home = 0
        case baseline = 1
        case surveys = 2
        case history = 3
        case profile = 4
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                authViewModel: authViewModel,
                homeViewModel: homeViewModel,
                surveyViewModel: surveyViewModel
            )
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(Tab.home)

            BaselineView()
                .tabItem { Label("Baseline", systemImage: "waveform") }
                .tag(Tab.baseline)

            SurveyView(
                surveyViewModel: surveyViewModel,
                uid: authViewModel.currentUser ?? ""
            )
            .tabItem { Label("Surveys", systemImage: "checkmark.circle.fill") }
            .tag(Tab.surveys)

            HistoryView(
                historyViewModel: historyViewModel,
                uid: authViewModel.currentUser ?? ""
            )
            .tabItem { Label("History", systemImage: "chart.bar.fill") }
            .tag(Tab.history)

            ProfileView(authViewModel: authViewModel)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .accentColor(.blue)
    }
}

