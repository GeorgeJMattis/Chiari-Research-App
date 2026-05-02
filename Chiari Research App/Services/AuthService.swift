//
//  AuthService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import FirebaseAuth
import Foundation

class AuthService {
    func signUp(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        return uid
    }
    
    func login(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid

        return uid
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> String? {
        return Auth.auth().currentUser?.uid
    }

    func getCurrentUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
}
