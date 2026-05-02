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
    func createUser(uid: String, email: String) async throws -> UserInfo
}