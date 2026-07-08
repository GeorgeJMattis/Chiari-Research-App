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
    @Published var isInitializing = true
    @Published var userInfo: UserInfo?

    private let authService = AuthService()
    private let userRepository: UserRepository = FirebaseUserRepository()
    private let enrollmentRepository: EnrollmentRepository = FirebaseEnrollmentRepository()

    init() {
        if let uid = authService.getCurrentUser() {
            isLoggedIn = true
            currentUser = uid
            UserDefaults.standard.set(uid, forKey: "currentUserUID")

            Task {
                await loadUserState(for: uid)
                isInitializing = false
                BackgroundTaskManager.schedulePressureCollection()
                SurveyScheduler.shared.scheduleDailyNotifications()
            }
        } else {
            isInitializing = false
        }
    }

    /// Enrolls the participant anonymously: signs in, creates their study
    /// record, and starts background collection + survey reminders. There is no
    /// separate onboarding step — sign-in is enrollment.
    func signInAnonymously(country: String? = nil, stateRegion: String? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let uid = try await authService.signInAnonymously()
            isLoggedIn = true
            currentUser = uid
            UserDefaults.standard.set(uid, forKey: "currentUserUID")

            userInfo = try await userRepository.createUser(uid: uid, country: country, stateRegion: stateRegion)

            BackgroundTaskManager.schedulePressureCollection()
            _ = await SurveyScheduler.shared.requestPermission()
            SurveyScheduler.shared.scheduleDailyNotifications()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Completes ResearchKit enrollment: signs the participant in anonymously,
    /// then records their consent + baseline symptoms. Called when the consent
    /// task finishes successfully.
    func enroll(symptoms: [String], country: String? = nil, stateRegion: String? = nil) async {
        await signInAnonymously(country: country, stateRegion: stateRegion)
        guard errorMessage == nil, let uid = currentUser else { return }
        do {
            try await enrollmentRepository.saveEnrollment(uid: uid, symptoms: symptoms, consentDate: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Updates the participant's editable geography and persists it.
    func updateGeography(country: String?, stateRegion: String?) async {
        guard var info = userInfo else { return }
        isLoading = true
        errorMessage = nil
        info.country = country
        info.stateRegion = stateRegion
        do {
            try await userRepository.updateUser(info)
            userInfo = info
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
            userInfo = nil
            errorMessage = nil
            UserDefaults.standard.removeObject(forKey: "currentUserUID")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadUserState(for uid: String) async {
        do {
            userInfo = try await userRepository.fetchUser(uid: uid)
        } catch {
            // Signed-in session with no study record yet — create one so the
            // app has study dates to work with.
            userInfo = try? await userRepository.createUser(uid: uid)
        }
    }
}
