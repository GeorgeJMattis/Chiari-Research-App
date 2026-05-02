//
//  OnboardingView.swift
//  Chiari Research App
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var medicalHistory = ""
    @State private var symptoms = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Medical History") {
                        TextEditor(text: $medicalHistory)
                            .frame(height: 100)
                    }
                    
                    Section("Symptoms") {
                        TextEditor(text: $symptoms)
                            .frame(height: 100)
                    }
                }
                
                Button(action: completeOnboarding) {
                    Text("Complete Setup")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .padding()
            }
            .navigationTitle("Complete Your Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func completeOnboarding() {
        // TODO: Save onboarding data to Firestore
        // For now, just mark as completed
        authViewModel.hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView(authViewModel: AuthViewModel())
}
