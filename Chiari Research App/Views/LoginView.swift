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
    @State private var showConsentPreview = false
    @State private var country = ""
    @State private var stateRegion = ""

    /// Requires a country, plus a state when the country is the US.
    private var canJoin: Bool {
        guard !country.isEmpty else { return false }
        if country == Geography.unitedStates { return !stateRegion.isEmpty }
        return true
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 10) {
                #if UI_ONLY_BETA
                Text("MyChiariBeta")
                    .font(.largeTitle)
                    .bold()
                Text("Interface Preview")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                #else
                Text("Chiari Research")
                    .font(.largeTitle)
                    .bold()
                Text("Beta")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                #endif
            }

            #if UI_ONLY_BETA
            Text("This is a preview of the app's interface. It's not a research study, and no data is collected, stored, or sent anywhere. Everything you see is sample data on your device.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
            #else
            Text("Join the study anonymously. We never collect your name or email, only your region, the baseline health questionnaire, and the sensor and symptom data you choose to share.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
            #endif

            // Coarse geography, collected once at enrollment.
            VStack(spacing: 14) {
                GeographyPicker(country: $country, stateRegion: $stateRegion)
            }
            .padding(16)
            .background(.gray.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
            .padding(.horizontal, 8)

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
                    #if UI_ONLY_BETA
                    Text("Continue")
                    #else
                    Text("Join Study")
                    #endif
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(canJoin ? .blue : .blue.opacity(0.4))
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 10))
            .disabled(authViewModel.isLoading || !canJoin)
        }
        .padding(24)
        #if RESEARCHKIT_ENABLED
        .fullScreenCover(isPresented: $showEnrollment) {
            ResearchKitTaskView(task: EnrollmentTask.make()) { symptoms in
                showEnrollment = false
                Task { await authViewModel.enroll(symptoms: symptoms, country: country, stateRegion: stateRegion) }
            } onCancel: {
                showEnrollment = false
            }
            .ignoresSafeArea()
        }
        #endif
        #if UI_ONLY_BETA
        .sheet(isPresented: $showConsentPreview) {
            ConsentPreviewView(
                onContinue: {
                    showConsentPreview = false
                    Task { await authViewModel.signInAnonymously(country: country, stateRegion: stateRegion) }
                },
                onCancel: { showConsentPreview = false }
            )
        }
        #endif
    }

    private func joinTapped() {
        #if RESEARCHKIT_ENABLED
        // Present consent + baseline survey; enrollment completes in the
        // task's completion handler above.
        showEnrollment = true
        #elseif UI_ONLY_BETA
        // Preview build: show a placeholder of the consent forms the real study
        // would present, then continue using sample data.
        showConsentPreview = true
        #else
        // No ResearchKit yet, so enroll directly.
        Task { await authViewModel.signInAnonymously(country: country, stateRegion: stateRegion) }
        #endif
    }
}

#Preview {
    WelcomeView(authViewModel: AuthViewModel())
}
