//
//  LoginView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//
//  Hosts WelcomeView (anonymous enrollment). When RESEARCHKIT_ENABLED is set,
//  "Join Study" presents the ResearchKit consent + baseline survey; otherwise
//  it signs in anonymously directly (so the app builds before the ResearchKit
//  package is added). The file can be renamed to WelcomeView.swift in Xcode.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showEnrollment = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 10) {
                Text("Chiari Research")
                    .font(.largeTitle)
                    .bold()
                Text("Beta")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Join the study anonymously. We never collect your name, email, or any personal identifiers — only the sensor and symptom data you choose to share.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Spacer()

            Button(action: joinTapped) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Join Study")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 10))
            .disabled(authViewModel.isLoading)
        }
        .padding(24)
        #if RESEARCHKIT_ENABLED
        .fullScreenCover(isPresented: $showEnrollment) {
            ResearchKitTaskView(task: EnrollmentTask.make()) { symptoms in
                showEnrollment = false
                Task { await authViewModel.enroll(symptoms: symptoms) }
            } onCancel: {
                showEnrollment = false
            }
            .ignoresSafeArea()
        }
        #endif
    }

    private func joinTapped() {
        #if RESEARCHKIT_ENABLED
        // Present consent + baseline survey; enrollment completes in the
        // task's completion handler above.
        showEnrollment = true
        #else
        // No ResearchKit yet — enroll directly.
        Task { await authViewModel.signInAnonymously() }
        #endif
    }
}

#Preview {
    WelcomeView(authViewModel: AuthViewModel())
}
