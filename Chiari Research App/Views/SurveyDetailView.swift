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
    @State private var hadBalanceProblem: Bool = false
    @State private var balance: Double = 5
    @State private var hadNumbness: Bool = false
    @State private var numbnessTingling: Double = 5
    @State private var cheerful: Double = 0
    @State private var sad: Double = 0
    @State private var anxious: Double = 0
    @State private var prefill: SurveyResponses? = nil
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var currentResponses: SurveyResponses {
        SurveyResponses(
            hadHeadache: hadHeadache,
            painLevel: painLevel,
            hadBalanceProblem: hadBalanceProblem,
            balance: balance,
            hadNumbness: hadNumbness,
            numbnessTingling: numbnessTingling,
            cheerful: cheerful,
            sad: sad,
            anxious: anxious
        )
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

                // Question 3: Balance problems (Yes/No, then severity)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Did you have balance problems today?")
                        .font(.headline)
                    HStack(spacing: 12) {
                        ChoiceButton(label: "Yes", isSelected: hadBalanceProblem) {
                            hadBalanceProblem = true
                        }
                        ChoiceButton(label: "No", isSelected: !hadBalanceProblem) {
                            hadBalanceProblem = false
                        }
                    }
                }
                if hadBalanceProblem {
                    SliderQuestionCard(title: "Balance severity", value: $balance, range: 1...10, lowLabel: "Mild", highLabel: "Severe")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Question 4: Numbness or tingling (Yes/No, then severity)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Did you have numbness or tingling today?")
                        .font(.headline)
                    HStack(spacing: 12) {
                        ChoiceButton(label: "Yes", isSelected: hadNumbness) {
                            hadNumbness = true
                        }
                        ChoiceButton(label: "No", isSelected: !hadNumbness) {
                            hadNumbness = false
                        }
                    }
                }
                if hadNumbness {
                    SliderQuestionCard(title: "Numbness or tingling severity", value: $numbnessTingling, range: 1...10, lowLabel: "Mild", highLabel: "Severe")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Mood check-ins (always shown), each 0–10
                SliderQuestionCard(title: "How cheerful do you feel?", value: $cheerful, lowLabel: "Not at all", highLabel: "Very")
                SliderQuestionCard(title: "How sad do you feel?", value: $sad, lowLabel: "Not at all", highLabel: "Very")
                SliderQuestionCard(title: "How anxious do you feel?", value: $anxious, lowLabel: "Not at all", highLabel: "Very")

                if let err = errorMessage {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
            .padding(16)
            .animation(.easeInOut(duration: 0.2), value: hadHeadache)
            .animation(.easeInOut(duration: 0.2), value: hadBalanceProblem)
            .animation(.easeInOut(duration: 0.2), value: hadNumbness)
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
            hadHeadache       = p.hadHeadache
            painLevel         = p.painLevel
            hadBalanceProblem = p.hadBalanceProblem
            balance           = p.balance
            hadNumbness       = p.hadNumbness
            numbnessTingling  = p.numbnessTingling
            cheerful          = p.cheerful
            sad               = p.sad
            anxious           = p.anxious
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

/// A 0–10 slider question card, styled like the headache pain slider.
private struct SliderQuestionCard: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...10
    let lowLabel: String
    let highLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(String(format: "%.0f / 10", value))
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            Slider(value: $value, in: range, step: 1)
                .tint(.blue)
            HStack {
                Text(lowLabel).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(highLabel).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
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

