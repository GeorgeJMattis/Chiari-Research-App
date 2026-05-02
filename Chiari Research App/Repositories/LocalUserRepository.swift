//
//  LocalUserRepository.swift
//  Chiari Research App
//

import Foundation

class LocalUserRepository: UserRepository {
    private let storageService = StorageService()
    private let userInfoKeyPrefix = "userInfo_"
    
    private func userInfoKey(for uid: String) -> String {
        return userInfoKeyPrefix + uid
    }
    
    func fetchUser(uid: String) async throws -> UserInfo {
        let key = userInfoKey(for: uid)
        // Try to load from disk
        if let data = UserDefaults.standard.data(forKey: key),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return userInfo
        }
        
        // If not found, throw error
        throw NSError(domain: "UserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }
    
    func updateUser(_ user: UserInfo) async throws {
        let key = userInfoKey(for: user.uid)
        // Save to UserDefaults
        let encoded = try JSONEncoder().encode(user)
        UserDefaults.standard.set(encoded, forKey: key)
    }
    
    func createUser(uid: String, email: String) async throws -> UserInfo {
        // Create new user with just uid and email
        let userInfo = UserInfo(
            uid: uid,
            email: email,
            name: nil,
            country: nil,
            state: nil,
            hasCompletedOnboarding: false
        )
        
        // Save to local storage
        try await updateUser(userInfo)
        return userInfo
    }
}
