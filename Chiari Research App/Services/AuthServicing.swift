//
//  AuthServicing.swift
//  Chiari Research App
//
//  Shared (Firebase-free) protocol so ViewModels can depend on either the real
//  Firebase-backed AuthService or a mock implementation without ever importing
//  Firebase themselves.
//

import Foundation

protocol AuthServicing {
    func signInAnonymously() async throws -> String
    func logout() throws
    func getCurrentUser() -> String?
}
