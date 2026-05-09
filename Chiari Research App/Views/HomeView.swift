//
//  HomeView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(authViewModel.userInfo?.name ?? "User")")
                        .font(.title2)
                        .bold()
                    Text("Track your symptoms and pressure data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))

                Spacer()

                // Logout Button
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding(16)
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
}
