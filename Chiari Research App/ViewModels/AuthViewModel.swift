//
//  AuthViewModel.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Integrate with AuthService
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        
        if !email.isEmpty && !password.isEmpty {
            isLoggedIn = true
            currentUser = email
        } else {
            errorMessage = "Email and password are required"
        }
        
        isLoading = false
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        errorMessage = nil
    }
}
