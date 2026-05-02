//
//  HistoryView.swift
//  Chiari Research App
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("History View")
                    .font(.title)
                Text("Your history coming soon")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
