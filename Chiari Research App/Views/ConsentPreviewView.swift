//
//  ConsentPreviewView.swift
//  Chiari Research App
//
//  Placeholder shown in the preview build in place of the real ResearchKit
//  consent flow. It describes the consent forms and privacy protections the
//  full study would use. It does not collect or store anything.
//

import SwiftUI

struct ConsentPreviewView: View {
    var onContinue: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("This screen previews the consent process. In the full study you would review and sign the forms below before enrolling. Nothing here is collected or stored.")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    section(
                        icon: "doc.text",
                        title: "App Consent Form",
                        detail: "Explains how the app works, what it does on your device, and what information it uses, so you know what you are agreeing to before you begin."
                    )

                    section(
                        icon: "checkmark.seal",
                        title: "IRB Informed Consent Form",
                        detail: "A formal informed consent document reviewed and approved by an Institutional Review Board (IRB). It describes the study, its purpose, any risks and benefits, and your rights as a participant, including your right to withdraw at any time."
                    )

                    Divider()

                    section(
                        icon: "lock.shield",
                        title: "Your Privacy",
                        detail: "We do not collect your name or email. Enrollment is anonymous. Your sign in and every request for your data are protected by secure Firebase authentication tokens, so your information is tied to an anonymous ID rather than to your identity."
                    )
                }
                .padding(24)
            }
            .navigationTitle("Consent Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: onContinue) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 10))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .background(.bar)
            }
        }
    }

    private func section(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ConsentPreviewView(onContinue: {}, onCancel: {})
}
