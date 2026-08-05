//
//  FirebaseEnrollmentRepository.swift
//  Chiari Research App
//

import Foundation
import FirebaseFirestore

class FirebaseEnrollmentRepository: EnrollmentRepository {
    private let db = Firestore.firestore()

    func saveEnrollment(uid: String, symptoms: [String], consentDate: Date) async throws {
        let data: [String: Any] = [
            "uid": uid,
            "topFiveSymptoms": symptoms,
            "consentDate": consentDate,
            "consentVersion": "1.0",
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("enrollments").document(uid).setData(data, merge: true)
    }
}
