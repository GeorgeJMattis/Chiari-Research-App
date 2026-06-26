//
//  EnrollmentRepository.swift
//  Chiari Research App
//
//  Persists the one-time enrollment record produced by the ResearchKit consent
//  + baseline survey: the consent timestamp/version and the participant's
//  baseline symptoms. Keyed by the anonymous UID; holds no personal identifiers.
//

import Foundation
import FirebaseFirestore

protocol EnrollmentRepository {
    func saveEnrollment(uid: String, symptoms: [String], consentDate: Date) async throws
}

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
