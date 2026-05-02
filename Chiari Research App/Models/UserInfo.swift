//
//  UserInfo.swift
//  Chiari Research App
//

import Foundation

struct UserInfo: Codable {
    let uid: String
    var email: String
    var name: String?
    var country: String?
    var state: String?
    var hasCompletedOnboarding: Bool
}