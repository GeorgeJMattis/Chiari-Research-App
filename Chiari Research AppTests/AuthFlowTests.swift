//
//  AuthFlowTests.swift
//  Chiari Research AppTests
//

import XCTest
@testable import Chiari_Research_App
import FirebaseAuth
import FirebaseFirestore

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
        // Clean up: logout after each test
        try? authViewModel.logout()
    }
    
    // MARK: - Test 1: Fresh Signup
    func testFreshSignup() async throws {
        print("🧪 TEST 1: Fresh Signup")
        
        let testEmail = "test_\(UUID().uuidString)@example.com"
        let testPassword = "TestPassword123!"
        
        // Sign up
        await authViewModel.signUp(email: testEmail, password: testPassword)
        
        XCTAssertTrue(authViewModel.isLoggedIn, "Should be logged in after signup")
        XCTAssertNotNil(authViewModel.currentUser, "Should have currentUser")
        XCTAssertFalse(authViewModel.hasCompletedOnboarding, "Should not have completed onboarding yet")
        
        print("✅ Signup successful. UID: \(authViewModel.currentUser ?? "unknown")")
    }
    
    // MARK: - Test 2: Signup → Onboarding → Data in Firestore
    func testSignupAndOnboardingPersists() async throws {
        print("🧪 TEST 2: Signup → Onboarding → Firestore Persistence")
        
        let testEmail = "test_onboard_\(UUID().uuidString)@example.com"
        let testPassword = "TestPassword123!"
        
        // Step 1: Sign up
        await authViewModel.signUp(email: testEmail, password: testPassword)
        let uid = authViewModel.currentUser!
        print("Step 1 ✓ Signed up with UID: \(uid)")
        
        // Step 2: Simulate onboarding data
        let repository = FirebaseUserRepository()
        var userInfo = UserInfo(
            uid: uid,
            email: testEmail,
            name: "Test User",
            country: "United States",
            state: "California",
            hasCompletedOnboarding: true
        )
        
        try await repository.updateUser(userInfo)
        print("Step 2 ✓ Updated user with onboarding data")
        
        // Step 3: Verify it's in Firestore
        let fetchedUser = try await repository.fetchUser(uid: uid)
        XCTAssertEqual(fetchedUser.name, "Test User", "Name should be saved")
        XCTAssertEqual(fetchedUser.country, "United States", "Country should be saved")
        XCTAssertTrue(fetchedUser.hasCompletedOnboarding, "Should be marked as completed")
        print("Step 3 ✓ Verified data in Firestore")
    }
    
    // MARK: - Test 3: Account Isolation (switching users)
    func testAccountIsolation() async throws {
        print("🧪 TEST 3: Account Isolation")
        
        let email1 = "user1_\(UUID().uuidString)@example.com"
        let email2 = "user2_\(UUID().uuidString)@example.com"
        let password = "TestPassword123!"
        
        // User 1: Sign up
        await authViewModel.signUp(email: email1, password: password)
        let uid1 = authViewModel.currentUser!
        let repo1 = FirebaseUserRepository()
        
        var user1Info = UserInfo(
            uid: uid1,
            email: email1,
            name: "User One",
            country: "USA",
            state: "CA",
            hasCompletedOnboarding: true
        )
        try await repo1.updateUser(user1Info)
        print("Step 1 ✓ User 1 signed up and onboarded: \(uid1)")
        
        // Logout
        authViewModel.logout()
        XCTAssertFalse(authViewModel.isLoggedIn, "Should be logged out")
        print("Step 2 ✓ Logged out")
        
        // User 2: Sign up
        await authViewModel.signUp(email: email2, password: password)
        let uid2 = authViewModel.currentUser!
        let repo2 = FirebaseUserRepository()
        
        XCTAssertNotEqual(uid1, uid2, "UIDs should be different")
        print("Step 3 ✓ User 2 signed up: \(uid2)")
        
        // Verify User 2's data doesn't have User 1's info
        var user2Info = try await repo2.fetchUser(uid: uid2)
        XCTAssertNotEqual(user2Info.name, "User One", "User 2 should not have User 1's name")
        XCTAssertFalse(user2Info.hasCompletedOnboarding, "User 2 should not be marked as completed yet")
        print("Step 4 ✓ User 2's data is isolated (no User 1 data)")
        
        // Verify User 1's data is still intact
        let userOneData = try await repo1.fetchUser(uid: uid1)
        XCTAssertEqual(userOneData.name, "User One", "User 1 data should still exist")
        print("Step 5 ✓ User 1's data still intact in Firestore")
    }
    
    // MARK: - Test 4: No Ghost Data
    func testNoGhostDataCreated() async throws {
        print("🧪 TEST 4: No Ghost Data")
        
        let testEmail = "ghost_test_\(UUID().uuidString)@example.com"
        let testPassword = "TestPassword123!"
        
        // Sign up
        await authViewModel.signUp(email: testEmail, password: testPassword)
        let uid = authViewModel.currentUser!
        print("Step 1 ✓ Signed up with UID: \(uid)")
        
        // Check Firestore document
        let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
        XCTAssertTrue(doc.exists, "User document should exist")
        
        let data = doc.data() ?? [:]
        XCTAssertEqual(data["email"] as? String, testEmail, "Email should match signup email")
        XCTAssertNil(data["name"] as? String, "Name should be nil until onboarding")
        XCTAssertFalse(data["hasCompletedOnboarding"] as? Bool ?? false, "Should not be marked as completed")
        
        print("Step 2 ✓ Only signup data exists, no ghost/old data")
    }
}
