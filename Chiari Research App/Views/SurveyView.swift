//
//  SurveyView.swift
//  Chiari Research App
//

import SwiftUI

struct SurveyView: View {
    @ObservedObject var surveyViewModel: SurveyViewModel
    let uid: String

    var body: some View {
        NavigationStack {
            Group {
                if surveyViewModel.isLoading {
                    ProgressView()
                } else {
                    List(surveyViewModel.todaySlots) { slotStatus in
                        NavigationLink {
                            SurveyDetailView(
                                slot: slotStatus,
                                surveyViewModel: surveyViewModel,
                                uid: uid
                            )
                        } label: {
                            SlotRowView(status: slotStatus)
                        }
                        .disabled(slotStatus.isCompleted)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Surveys")
            .task { await surveyViewModel.loadToday(uid: uid) }
        }
    }
}

struct SlotRowView: View {
    let status: SurveyViewModel.SlotStatus

    var body: some View {
        HStack(spacing: 16) {
            // Time column
            VStack(alignment: .center, spacing: 2) {
                Text(status.scheduledTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption).bold()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 54)

            // Slot info
            VStack(alignment: .leading, spacing: 4) {
                Text(status.slot.displayName)
                    .font(.headline)
                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Spacer()

            // State icon
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.title3)
        }
        .padding(.vertical, 6)
        .opacity(status.isMissed ? 0.5 : 1)
    }

    private var statusLabel: String {
        if status.isCompleted { return "Completed" }
        if status.isMissed    { return "Missed" }
        if status.isUpcoming  { return "Upcoming" }
        return "Due now"
    }

    private var statusIcon: String {
        if status.isCompleted { return "checkmark.circle.fill" }
        if status.isMissed    { return "xmark.circle" }
        if status.isUpcoming  { return "clock" }
        return "exclamationmark.circle.fill"
    }

    private var statusColor: Color {
        if status.isCompleted { return .green }
        if status.isMissed    { return .gray }
        if status.isUpcoming  { return .blue }
        return .orange
    }
}

#Preview {
    SurveyView(surveyViewModel: SurveyViewModel(), uid: "preview")
}

