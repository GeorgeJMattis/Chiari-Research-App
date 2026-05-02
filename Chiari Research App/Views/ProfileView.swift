//
//  ProfileView.swift
//  Chiari Research App
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile View")
                    .font(.title)
                Text("User: \(authViewModel.currentUser ?? "Unknown")")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: { authViewModel.logout() }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
