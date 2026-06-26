//
//  FirebaseUserRepository.swift
//  Chiari Research App
//

import Foundation
import FirebaseFirestore

class FirebaseUserRepository: UserRepository {
    private let db = Firestore.firestore()

    
    func fetchUser(uid: String) async throws -> UserInfo {
        let document = try await db.collection("users").document(uid).getDocument()
        guard document.exists else {
            throw NSError(domain: "UserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        let data = document.data() ?? [:]

        let userInfo = UserInfo(
            uid: uid,
            studyStartDate: (data["studyStartDate"] as? Timestamp)?.dateValue(),
            studyDurationDays: data["studyDurationDays"] as? Int ?? 30
        )
        return userInfo
    }

    func updateUser(_ user: UserInfo) async throws {
        let data: [String: Any?] = [
            "uid": user.uid,
            "studyStartDate": user.studyStartDate as Any,
            "studyDurationDays": user.studyDurationDays,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(user.uid).setData(data, merge: true)
    }

    func createUser(uid: String) async throws -> UserInfo {
        let now = Date()
        let userInfo = UserInfo(uid: uid, studyStartDate: now, studyDurationDays: 30)

        let data: [String: Any?] = [
            "uid": uid,
            "studyStartDate": now,
            "studyDurationDays": 30,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(uid).setData(data)

        // Increment global participant counter
        try await db.collection("stats").document("global").setData(
            ["participantCount": FieldValue.increment(Int64(1))],
            merge: true
        )
        return userInfo
    }

    func fetchParticipantCount() async throws -> Int {
        let doc = try await db.collection("stats").document("global").getDocument()
        return (doc.data()?["participantCount"] as? Int) ?? 0
    }
}
