//
//  OnboardingView.swift
//  Chiari Research App
//
//  Onboarding was removed in the anonymous-auth overhaul (no name/country/state,
//  and enrollment now happens at sign-in). This file is no longer used; it is
//  kept only as a compiling stub so the Xcode project reference stays valid.
//  Delete it in Xcode when the ResearchKit consent + intake flow lands (step 3).
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        EmptyView()
    }
}
