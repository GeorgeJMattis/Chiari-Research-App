//
//  SurveyDetailView.swift
//  Chiari Research App
//

import SwiftUI

struct SurveyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let slot: SurveyViewModel.SlotStatus
    @ObservedObject var surveyViewModel: SurveyViewModel
    let uid: String

    @State private var hadHeadache: Bool = false
    @State private var painLevel: Double = 5
    @State private var prefill: SurveyResponses? = nil
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var currentResponses: SurveyResponses {
        SurveyResponses(hadHeadache: hadHeadache, painLevel: painLevel)
    }

    private var hasChangedFromPrefill: Bool {
        currentResponses != prefill
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(slot.slot.displayName)
                        .font(.title2).bold()
                    Text(slot.scheduledTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline).foregroundStyle(.secondary)
                    if prefill != nil {
                        Text("Pre-filled from yesterday")
                            .font(.caption).foregroundStyle(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.gray.opacity(0.08))
                .clipShape(.rect(cornerRadius: 12))

                // Question 1: Headache
                VStack(alignment: .leading, spacing: 12) {
                    Text("Did you have a headache today?")
                        .font(.headline)
                    HStack(spacing: 12) {
                        ChoiceButton(label: "Yes", isSelected: hadHeadache) {
                            hadHeadache = true
                        }
                        ChoiceButton(label: "No", isSelected: !hadHeadache) {
                            hadHeadache = false
                        }
                    }
                }

                // Question 2: Pain level (only shown if hadHeadache)
                if hadHeadache {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Pain severity")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.0f / 10", painLevel))
                                .font(.headline)
                                .foregroundStyle(painColor)
                        }
                        Slider(value: $painLevel, in: 1...10, step: 1)
                            .tint(painColor)
                        HStack {
                            Text("Mild").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("Severe").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .background(.gray.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let err = errorMessage {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
            .padding(16)
            .animation(.easeInOut(duration: 0.2), value: hadHeadache)
        }
        .navigationTitle("Check-in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(hasChangedFromPrefill ? "Submit" : "No Change") {
                    Task { await submit() }
                }
                .disabled(isSubmitting || slot.isCompleted)
                .bold(hasChangedFromPrefill)
            }
        }
        .task { await loadPrefill() }
        .disabled(slot.isCompleted)
    }

    private var painColor: Color {
        switch painLevel {
        case 1...3:  return .green
        case 4...6:  return .orange
        default:     return .red
        }
    }

    private func loadPrefill() async {
        prefill = await surveyViewModel.fetchPrefill(uid: uid, slot: slot.slot)
        if let p = prefill {
            hadHeadache = p.hadHeadache
            painLevel   = p.painLevel
        }
    }

    private func submit() async {
        isSubmitting = true
        do {
            try await surveyViewModel.submit(
                responses: currentResponses,
                uid: uid,
                slot: slot.slot
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}

private struct ChoiceButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    let slot = SurveyViewModel.SlotStatus(
        slot: .morning,
        scheduledTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
        session: nil
    )
    NavigationStack {
        SurveyDetailView(slot: slot, surveyViewModel: SurveyViewModel(), uid: "preview")
    }
}

