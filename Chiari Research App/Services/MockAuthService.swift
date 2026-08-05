//
//  MockAuthService.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for AuthService — fakes a signed-in session with a
//  locally generated UID persisted in UserDefaults. No network call, ever.
//

import Foundation

class MockAuthService: AuthServicing {
    private let key = "mockBetaUID"

    func signInAnonymously() async throws -> String {
        let uid = UUID().uuidString
        UserDefaults.standard.set(uid, forKey: key)
        return uid
    }

    func logout() throws {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func getCurrentUser() -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
