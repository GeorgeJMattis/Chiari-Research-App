//
//  BaselineView.swift
//  Chiari Research App
//

import SwiftUI

struct BaselineView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Baseline View")
                    .font(.title)
                Text("Baseline measurements coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Baseline")
        }
    }
}

#Preview {
    BaselineView()
}
