//
//  EnrollmentRepository.swift
//  Chiari Research App
//
//  Persists the one-time enrollment record produced by the ResearchKit consent
//  + baseline survey: the consent timestamp/version and the participant's
//  baseline symptoms. Keyed by the anonymous UID; holds no personal identifiers.
//
//  Firebase-free so it can be shared by both the production and beta targets;
//  see FirebaseEnrollmentRepository.swift for the real implementation.
//

import Foundation

protocol EnrollmentRepository {
    func saveEnrollment(uid: String, symptoms: [String], consentDate: Date) async throws
}
