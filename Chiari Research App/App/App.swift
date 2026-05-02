//
//  Chiari_Research_AppApp.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct Chiari_Research_AppApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var surveyViewModel = SurveyViewModel()
    
    init() {
        // DEBUG: Clear persistent login to test signup flow
        try? Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "userInfo")
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if !authViewModel.isLoggedIn {
                LoginView(authViewModel: authViewModel)
            } else if !authViewModel.hasCompletedOnboarding {
                OnboardingView(authViewModel: authViewModel)
            } else {
                TabBarView(authViewModel: authViewModel, surveyViewModel: surveyViewModel)
            }
        }
    }
}
