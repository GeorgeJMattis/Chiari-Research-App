//
//  MockUserRepository.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for FirebaseUserRepository. In-memory only.
//

import Foundation

class MockUserRepository: UserRepository {
    private var storage: [String: UserInfo] = [:]

    func fetchUser(uid: String) async throws -> UserInfo {
        if let existing = storage[uid] { return existing }
        return try await createUser(uid: uid, country: nil, stateRegion: nil)
    }

    func updateUser(_ user: UserInfo) async throws {
        storage[user.uid] = user
    }

    func createUser(uid: String, country: String?, stateRegion: String?) async throws -> UserInfo {
        let start = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let info = UserInfo(uid: uid, studyStartDate: start, studyDurationDays: 30, country: country, stateRegion: stateRegion)
        storage[uid] = info
        return info
    }

    func fetchParticipantCount() async throws -> Int {
        128
    }
}
