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
    @Environment(\.scenePhase) private var scenePhase

    init() {
        FirebaseApp.configure()
        BackgroundTaskManager.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isInitializing {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !authViewModel.isLoggedIn {
                    WelcomeView(authViewModel: authViewModel)
                } else {
                    TabBarView(authViewModel: authViewModel)
                }
            }
            #if SENSORKIT_ENABLED
            .onChange(of: scenePhase) { phase in
                // Fetch any newly-available (24h-embargoed) SensorKit data each
                // time the app comes to the foreground for a signed-in user.
                guard phase == .active,
                      let uid = UserDefaults.standard.string(forKey: "currentUserUID") else { return }
                SensorKitManager.shared.activateAndFetch(uid: uid)
            }
            #endif
        }
    }
}