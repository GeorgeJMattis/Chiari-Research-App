//
//  HomeView.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/29/26.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isMeasuring = false
    @State private var measurementStatus: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(authViewModel.userInfo?.name ?? "User")")
                        .font(.title2)
                        .bold()
                    Text("Track your symptoms and pressure data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))

                // Take Measurement Button
                Button {
                    Task {
                        await takeMeasurement()
                    }
                } label: {
                    HStack {
                        if isMeasuring {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isMeasuring ? "Measuring..." : "Take Measurement")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isMeasuring ? .blue.opacity(0.5) : .blue)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 8))
                }
                .disabled(isMeasuring)

                if let status = measurementStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(status.contains("Failed") ? .red : .green)
                }

                Spacer()

                // Logout Button
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding(16)
            .navigationTitle("Home")
        }
    }

    private func takeMeasurement() async {
        guard let uid = authViewModel.currentUser else { return }

        isMeasuring = true
        measurementStatus = nil

        do {
            let sensorService = SensorService()
            try await sensorService.collectAndSave(uid: uid)

            let localRepo = LocalSensorRepository()
            let firebaseRepo = FirebaseSensorRepository()
            let unsyncedBatches = try await localRepo.fetchUnsyncedBatches()

            for batch in unsyncedBatches {
                try await firebaseRepo.saveBatch(batch)
                try await localRepo.markBatchAsSynced(batchID: batch.id)
            }

            measurementStatus = "Sent \(unsyncedBatches.count) batch(es)"
        } catch {
            measurementStatus = "Failed: \(error.localizedDescription)"
        }

        isMeasuring = false
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
}
