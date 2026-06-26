//
//  ProfileView.swift
//  Chiari Research App
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showLeaveConfirmation = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile View")
                    .font(.title)
                Text("Participant: \(authViewModel.currentUser ?? "Unknown")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(role: .destructive) {
                    showLeaveConfirmation = true
                } label: {
                    Text("Leave Study")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding()
            .navigationTitle("Profile")
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
        }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
