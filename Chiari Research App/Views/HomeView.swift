//
//  HomeView.swift
//  Chiari Research App
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var surveyViewModel: SurveyViewModel

    @State private var isMeasuring = false
    @State private var measurementStatus: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    studyHeader
                    calendarSection
                    todaysSurveys
                    measurementButton
                }
                .padding(16)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out") { authViewModel.logout() }
                        .foregroundStyle(.red)
                }
            }
            .task {
                guard let uid = authViewModel.currentUser,
                      let info = authViewModel.userInfo else { return }
                await homeViewModel.load(uid: uid, userInfo: info)
            }
        }
    }

    // MARK: - Study Header

    private var studyHeader: some View {
        HStack(spacing: 0) {
            StatCell(value: "\(homeViewModel.studyDay)", label: "Study Day")
            Divider().frame(height: 36)
            StatCell(value: "\(homeViewModel.daysRemaining)", label: "Days Left")
            Divider().frame(height: 36)
            StatCell(value: "\(homeViewModel.participantCount)", label: "Participants")
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - 30-Day Calendar

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Study Calendar")
                .font(.headline)

            let days = studyDays()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

            // Day-of-week header
            HStack(spacing: 0) {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                    Text(d)
                        .font(.caption2).bold()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                // Leading empty cells to align first day
                ForEach(0..<leadingBlanks(for: days.first ?? Date()), id: \.self) { _ in
                    Color.clear.frame(height: 38)
                }
                ForEach(days, id: \.self) { day in
                    DayCell(
                        date: day,
                        completedCount: homeViewModel.completionByDay[day] ?? 0,
                        isToday: Calendar.current.isDateInToday(day),
                        isFuture: day > Date()
                    )
                }
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Today's Survey Quick-View

    private var todaysSurveys: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Check-ins")
                .font(.headline)

            if surveyViewModel.todaySlots.isEmpty {
                ProgressView().frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 8) {
                    ForEach(surveyViewModel.todaySlots) { slot in
                        MiniSlotBadge(status: slot)
                    }
                }
            }
        }
        .padding(14)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Measurement Button

    private var measurementButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await takeMeasurement() }
            } label: {
                HStack {
                    if isMeasuring { ProgressView().tint(.white) }
                    Text(isMeasuring ? "Measuring..." : "Take Manual Measurement")
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
        }
    }

    // MARK: - Helpers

    private func studyDays() -> [Date] {
        guard let start = authViewModel.userInfo?.studyStartDate else {
            // Default: show current month
            return daysInCurrentMonth()
        }
        let cal = Calendar.current
        let duration = authViewModel.userInfo?.studyDurationDays ?? 30
        return (0..<duration).compactMap {
            cal.date(byAdding: .day, value: $0, to: cal.startOfDay(for: start))
        }
    }

    private func daysInCurrentMonth() -> [Date] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        guard let start = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    private func leadingBlanks(for date: Date) -> Int {
        Calendar.current.component(.weekday, from: date) - 1
    }

    private func takeMeasurement() async {
        guard let uid = authViewModel.currentUser else { return }
        isMeasuring = true
        measurementStatus = nil
        do {
            let sensorService = SensorService()
            try await sensorService.collectAndSave(uid: uid)
            let localRepo   = LocalSensorRepository()
            let firebaseRepo = FirebaseSensorRepository()
            let unsynced    = try await localRepo.fetchUnsyncedBatches()
            for batch in unsynced {
                try await firebaseRepo.saveBatch(batch)
                try await localRepo.markBatchAsSynced(batchID: batch.id)
            }
            measurementStatus = "Sent \(unsynced.count) batch(es)"
        } catch {
            measurementStatus = "Failed: \(error.localizedDescription)"
        }
        isMeasuring = false
    }
}

// MARK: - Sub-views

private struct StatCell: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title2).bold()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DayCell: View {
    let date: Date
    let completedCount: Int   // 0–4
    let isToday: Bool
    let isFuture: Bool

    private var ringColor: Color {
        switch completedCount {
        case 4:     return .green
        case 1...3: return .yellow
        default:    return .gray.opacity(0.3)
        }
    }

    private var progress: Double { Double(completedCount) / 4.0 }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 11, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isFuture ? .secondary : .primary)
            }
            .frame(width: 32, height: 32)
            .overlay(
                isToday ? Circle().stroke(Color.blue, lineWidth: 1.5) : nil
            )
        }
        .opacity(isFuture ? 0.45 : 1)
    }
}

private struct MiniSlotBadge: View {
    let status: SurveyViewModel.SlotStatus

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: status.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(status.isCompleted ? .green : (status.isMissed ? .gray : .blue))
                .font(.title3)
            Text(status.slot.displayName.prefix(3))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView(
        authViewModel: AuthViewModel(),
        homeViewModel: HomeViewModel(),
        surveyViewModel: SurveyViewModel()
    )
}

