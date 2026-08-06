//
//  ProfileView.swift
//  Chiari Research App
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showLeaveConfirmation = false

    @State private var country = ""
    @State private var stateRegion = ""
    @State private var showSaved = false

    /// Whether the edited geography differs from what's stored.
    private var hasChanges: Bool {
        country != (authViewModel.userInfo?.country ?? "")
            || stateRegion != (authViewModel.userInfo?.stateRegion ?? "")
    }

    private var canSave: Bool {
        guard !country.isEmpty, hasChanges, !authViewModel.isLoading else { return false }
        if country == Geography.unitedStates { return !stateRegion.isEmpty }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    GeographyPicker(country: $country, stateRegion: $stateRegion)
                }

                Section {
                    Button {
                        Task {
                            await authViewModel.updateGeography(
                                country: country.isEmpty ? nil : country,
                                stateRegion: stateRegion.isEmpty ? nil : stateRegion
                            )
                            if authViewModel.errorMessage == nil { showSaved = true }
                        }
                    } label: {
                        HStack {
                            Text("Save Changes")
                            if authViewModel.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(!canSave)
                }

                #if UI_ONLY_BETA
                Section("Preview") {
                    Text("This is a local preview session. No account or data is stored remotely.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                #else
                Section("Participant") {
                    Text(authViewModel.currentUser ?? "Unknown")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                #endif

                Section {
                    Button(role: .destructive) {
                        showLeaveConfirmation = true
                    } label: {
                        #if UI_ONLY_BETA
                        Text("Reset Preview")
                            .frame(maxWidth: .infinity)
                        #else
                        Text("Leave Study")
                            .frame(maxWidth: .infinity)
                        #endif
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                country = authViewModel.userInfo?.country ?? ""
                stateRegion = authViewModel.userInfo?.stateRegion ?? ""
            }
            .alert("Saved", isPresented: $showSaved) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your location has been updated.")
            }
            #if UI_ONLY_BETA
            .alert("Reset the preview?", isPresented: $showLeaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset Preview", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("This clears your local preview session. Nothing was collected or stored remotely, so there's nothing to lose.")
            }
            #else
            .alert("Leave the study?", isPresented: $showLeaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Leave Study", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                // Anonymous accounts have no email for recovery — signing out
                // permanently disconnects this device from its study data.
                Text("Because your participation is anonymous, leaving the study permanently disconnects this device from your collected data. This cannot be undone.")
            }
            #endif
        }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
