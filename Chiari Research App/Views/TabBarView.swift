//
//  TabBarView.swift
//  Chiari Research App
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var surveyViewModel: SurveyViewModel
    
    enum Tab: Int {
        case home = 0
        case baseline = 1
        case surveys = 2
        case history = 3
        case profile = 4
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(authViewModel: authViewModel)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)
            
            BaselineView()
                .tabItem { Label("Baseline", systemImage: "waveform") }
                .tag(Tab.baseline)
            
            SurveyView(surveyViewModel: surveyViewModel)
                .tabItem { Label("Surveys", systemImage: "checkmark.circle.fill") }
                .tag(Tab.surveys)
            
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar.fill") }
                .tag(Tab.history)
            
            ProfileView(authViewModel: authViewModel)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .accentColor(.blue)
    }

}