//
//  Chiari_Research_AppApp.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import SwiftUI
import FirebaseCore

@main
struct Chiari_Research_AppApp: App {
    @StateObject var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
        BackgroundTaskManager.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isInitializing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !authViewModel.isLoggedIn {
                LoginView(authViewModel: authViewModel)
            } else if !authViewModel.hasCompletedOnboarding {
                OnboardingView(authViewModel: authViewModel)
            } else {
                TabBarView(authViewModel: authViewModel)
            }
        }
    }
}