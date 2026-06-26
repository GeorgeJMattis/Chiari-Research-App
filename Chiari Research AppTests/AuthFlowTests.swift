//
//  AuthFlowTests.swift
//  Chiari Research AppTests
//
//  Anonymous auth flow. Requires Anonymous sign-in enabled in the Firebase
//  console and a network connection.
//

import XCTest
@testable import Chiari_Research_App
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthFlowTests: XCTestCase {
    var authViewModel: AuthViewModel!
    var db: Firestore!

    override func setUp() {
        super.setUp()
        authViewModel = AuthViewModel()
        db = Firestore.firestore()
    }

    override func tearDown() {
        super.tearDown()
        authViewModel.logout()
    }

    // MARK: - Test 1: Anonymous sign-in enrolls the participant
    func testAnonymousSignIn() async throws {
        await authViewModel.signInAnonymously()

        XCTAssertTrue(authViewModel.isLoggedIn, "Should be logged in after anonymous sign-in")
        XCTAssertNotNil(authViewModel.currentUser, "Should have a UID")
        XCTAssertNil(authViewModel.errorMessage, "Sign-in should not error")
    }

    // MARK: - Test 2: A study record (no PII) is created in Firestore
    func testStudyRecordPersists() async throws {
        await authViewModel.signInAnonymously()
        let uid = try XCTUnwrap(authViewModel.currentUser)

        let fetched = try await FirebaseUserRepository().fetchUser(uid: uid)
        XCTAssertEqual(fetched.uid, uid)
        XCTAssertNotNil(fetched.studyStartDate, "Study start date should be set at enrollment")
        XCTAssertEqual(fetched.studyDurationDays, 30)

        // Confirm no personal-identifier fields were written.
        let doc = try await db.collection("users").document(uid).getDocument()
        let data = doc.data() ?? [:]
        XCTAssertNil(data["email"], "No email should be stored")
        XCTAssertNil(data["name"], "No name should be stored")
        XCTAssertNil(data["country"], "No location should be stored")
    }

    // MARK: - Test 3: Each enrollment is a distinct anonymous identity
    func testAccountIsolation() async throws {
        await authViewModel.signInAnonymously()
        let uid1 = try XCTUnwrap(authViewModel.currentUser)

        authViewModel.logout()
        XCTAssertFalse(authViewModel.isLoggedIn, "Should be logged out")

        await authViewModel.signInAnonymously()
        let uid2 = try XCTUnwrap(authViewModel.currentUser)

        XCTAssertNotEqual(uid1, uid2, "A fresh anonymous sign-in should yield a new UID")
    }
}
