//
//  BetaDisclaimerView.swift
//  Chiari Research App
//
//  Shown once per install, before WelcomeView, only in the MyChiariBeta
//  target (UI_ONLY_BETA). Makes the preview/no-data-collection status
//  unmissable, independent of the enrollment screen's own copy.
//

import SwiftUI

struct BetaDisclaimerView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "eye.fill")
                .font(.system(size: 44))
                .foregroundStyle(.blue)

            VStack(spacing: 10) {
                Text("Preview Build")
                    .font(.largeTitle)
                    .bold()
                Text("This is a preview of MyChiariBeta's interface only. It is not a research study, and no data is collected, stored, or transmitted. Everything you see uses sample data on this device. No IRB review has been conducted for this preview.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
            }

            Spacer()

            Button(action: onContinue) {
                Text("I Understand and Continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(24)
    }
}

#Preview {
    BetaDisclaimerView(onContinue: {})
}
