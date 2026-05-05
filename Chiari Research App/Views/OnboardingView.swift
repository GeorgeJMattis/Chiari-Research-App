//
//  OnboardingView.swift
//  Chiari Research App
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var country = ""
    @State private var state = ""
    @State private var selectedSymptoms: Set<String> = []
    @State private var isLoading = false
    @State private var submissionError: String?
    
    let allSymptoms = ["Headaches", "Fatigue", "Dizziness", "Neck Pain", "Brain Fog", "Vision Changes", "Balance Issues"]
    let countries = ["United States", "Canada", "Mexico"]
    let usStates = ["California", "Texas", "Florida", "New York", "Pennsylvania", "Illinois", "Ohio", "Georgia", "North Carolina", "Michigan"]
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !country.isEmpty &&
        (country != "United States" || !state.isEmpty) &&
        selectedSymptoms.contains("Headaches") &&
        selectedSymptoms.count <= 5
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                }
                
                Section("Location") {
                    Picker("Country", selection: $country) {
                        Text("Select Country").tag("")
                        ForEach(countries, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    
                    if country == "United States" {
                        Picker("State", selection: $state) {
                            Text("Select State").tag("")
                            ForEach(usStates, id: \.self) { s in
                                Text(s).tag(s)
                            }
                        }
                    }
                }
                
                Section("Symptoms") {
                    Text("Select up to 5 symptoms (Headaches required)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(allSymptoms, id: \.self) { symptom in
                            Toggle(symptom, isOn: Binding(
                                get: { selectedSymptoms.contains(symptom) },
                                set: { isSelected in
                                    if isSelected && selectedSymptoms.count < 5 {
                                        selectedSymptoms.insert(symptom)
                                    } else if !isSelected {
                                        selectedSymptoms.remove(symptom)
                                    }
                                }
                            ))
                            .disabled(symptom != "Headaches" && selectedSymptoms.count >= 5 && !selectedSymptoms.contains(symptom))
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if !selectedSymptoms.contains("Headaches") {
                        Text("Headaches must be selected")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Button(action: completeOnboarding) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Complete Setup")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isLoading)

                    if let submissionError {
                        Text(submissionError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Complete Your Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func completeOnboarding() {
        isLoading = true
        submissionError = nil
        
        guard let uid = authViewModel.currentUser else {
            isLoading = false
            submissionError = "Missing signed-in user."
            return
        }
        
let userRepository: UserRepository = FirebaseUserRepository()
        
        Task {
            do {
                let existingUser = try? await userRepository.fetchUser(uid: uid)
                var userInfo = existingUser ?? UserInfo(
                    uid: uid,
                    email: authViewModel.currentUserEmail ?? "",
                    name: nil,
                    country: nil,
                    state: nil,
                    hasCompletedOnboarding: false
                )
                
                userInfo.name = name
                userInfo.country = country
                userInfo.state = country == "United States" ? state : nil
                userInfo.hasCompletedOnboarding = true
                
                try await userRepository.updateUser(userInfo)

                _ = BaselineInfo(topFiveSymptoms: Array(selectedSymptoms))

                await MainActor.run {
                    authViewModel.hasCompletedOnboarding = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    submissionError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    OnboardingView(authViewModel: AuthViewModel())
}
