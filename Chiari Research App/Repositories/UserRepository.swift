//
//  UserRepository.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import Foundation

protocol UserRepository {
    func fetchUser(uid: String) async throws -> UserInfo
    func updateUser(_ user: UserInfo) async throws
    func createUser(uid: String, country: String?, stateRegion: String?) async throws -> UserInfo
}

extension UserRepository {
    /// Convenience for callers that don't supply geography (e.g. recovering a
    /// signed-in session that has no study record yet).
    func createUser(uid: String) async throws -> UserInfo {
        try await createUser(uid: uid, country: nil, stateRegion: nil)
    }
}