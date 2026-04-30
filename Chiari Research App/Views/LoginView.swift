//
//  LoginView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Chiari Research")
                    .font(.title)
                    .bold()
                Text("Beeep Booop")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 40)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.bottom, 20)
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await authViewModel.login(email: email, password: password)
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 8))
            .disabled(authViewModel.isLoading)
            
            Spacer()
            
            Text("Demo: Use any email/password")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}
