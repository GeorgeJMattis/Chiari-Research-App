//
//  MockEnrollmentRepository.swift
//  Chiari Research App
//
//  UI_ONLY_BETA stand-in for FirebaseEnrollmentRepository. No-op.
//

import Foundation

class MockEnrollmentRepository: EnrollmentRepository {
    func saveEnrollment(uid: String, symptoms: [String], consentDate: Date) async throws {}
}
