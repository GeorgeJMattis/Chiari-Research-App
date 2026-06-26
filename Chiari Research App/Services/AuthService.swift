//
//  AuthService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import FirebaseAuth
import Foundation

class AuthService {
    /// Signs the participant in anonymously. Firebase issues a persistent UID
    /// with no email/password. Requires Anonymous auth to be enabled in the
    /// Firebase console (Authentication → Sign-in method → Anonymous).
    func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
