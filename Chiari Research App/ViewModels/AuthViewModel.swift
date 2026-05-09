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
    @Published var currentUserEmail: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var hasCompletedOnboarding = false
    @Published var isInitializing = true

    private let authService = AuthService()
    private let userRepository: UserRepository = FirebaseUserRepository()

    init() {
        if let uid = authService.getCurrentUser() {
            isLoggedIn = true
            currentUser = uid
            currentUserEmail = authService.getCurrentUserEmail()

            Task {
                await loadUserState(for: uid)
                isInitializing = false
            }
        } else {
            isInitializing = false
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let uid = try await authService.login(email: email, password: password)
            isLoggedIn = true
            currentUser = uid
            currentUserEmail = email
            await loadUserState(for: uid)
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
            currentUserEmail = email

            let userInfo = try await userRepository.createUser(uid: uid, email: email)
            hasCompletedOnboarding = userInfo.hasCompletedOnboarding
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
            currentUserEmail = nil
            hasCompletedOnboarding = false
            errorMessage = nil

       } catch {
            errorMessage = error.localizedDescription
       }
       isLoading = false
    }

    func completeOnboarding(name: String, country: String, state: String?, symptoms: [String]) async {
        guard let uid = currentUser else {
            errorMessage = "Missing signed-in user."
            return
        }
        
        do {
            let existingUser = try? await userRepository.fetchUser(uid: uid)
            var userInfo = existingUser ?? UserInfo(
                uid: uid,
                email: currentUserEmail ?? "",
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
            
            // Save baseline
            _ = BaselineInfo(topFiveSymptoms: symptoms)
            
            self.hasCompletedOnboarding = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadUserState(for uid: String) async {
        do {
            let userInfo = try await userRepository.fetchUser(uid: uid)
            hasCompletedOnboarding = userInfo.hasCompletedOnboarding
            currentUserEmail = userInfo.email
        } catch {
            hasCompletedOnboarding = false
        }
    }
}
