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
    @Published var hasCompletedOnboarding = false

    private let authService = AuthService()

    init() {
        if let uid = authService.getCurrentUser() {
            isLoggedIn = true
            currentUser = uid
        }
    }

    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let uid = try await authService.login(email: email, password: password)
            isLoggedIn = true
            currentUser = uid

        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let uid = try await authService.signUp(email: email, password: password)
            isLoggedIn = true
            currentUser = uid
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func logout() {
        isLoading = true
        errorMessage = nil
        do { 
            try authService.logout()
            isLoggedIn = false
            currentUser = nil
            errorMessage = nil

       } catch {
            errorMessage = error.localizedDescription
       }
       isLoading = false
    }
}
