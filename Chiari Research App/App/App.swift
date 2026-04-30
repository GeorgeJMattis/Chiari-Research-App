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
    @StateObject var surveyViewModel = SurveyViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                HomeView(authViewModel: authViewModel, surveyViewModel: surveyViewModel)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
    }
}
