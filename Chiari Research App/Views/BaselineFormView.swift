//
//  BaselineFormView.swift
//  Chiari Research App
//
//  Generic renderer for any BaselineQuestionnaire. Iterates the questions,
//  hides those whose ShowCondition isn't met, renders one control per
//  QuestionType, validates required answers, and hands the collected answers
//  back via `onSubmit`.
//

import SwiftUI

struct BaselineFormView: View {
    let questionnaire: BaselineQuestionnaire
    let onSubmit: ([String: BaselineAnswer]) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var answers: [String: BaselineAnswer]
    @State private var isSubmitting = false

    init(questionnaire: BaselineQuestionnaire,
         existing: BaselineResponse?,
         onSubmit: @escaping ([String: BaselineAnswer]) async -> Void) {
        self.questionnaire = questionnaire
        self.onSubmit = onSubmit
        _answers = State(initialValue: existing?.answers ?? [:])
    }

    // MARK: Visibility & validation

    private var visibleQuestions: [BaselineQuestion] {
        questionnaire.questions.filter(isVisible)
    }

    private func isVisible(_ q: BaselineQuestion) -> Bool {
        guard let cond = q.condition else { return true }
        guard let ans = answers[cond.questionID] else { return false }
        return !Set(ans.matchStrings).isDisjoint(with: Set(cond.equals))
    }

    private var missingRequired: Bool {
        for q in visibleQuestions where !q.isOptional {
            guard let a = answers[q.id], a.isAnswered else { return true }
        }
        return false
    }

    var body: some View {
        Form {
            ForEach(visibleQuestions) { question in
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 4) {
                            Text(question.prompt)
                                .font(.subheadline).bold()
                            if !question.isOptional {
                                Text("*").foregroundStyle(.red)
                            }
                        }
                        control(for: question)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Button {
                    submit()
                } label: {
                    HStack {
                        Spacer()
                        if isSubmitting { ProgressView().tint(.white) }
                        Text(isSubmitting ? "Saving..." : "Submit")
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(missingRequired ? Color.blue.opacity(0.4) : Color.blue)
                .foregroundStyle(.white)
                .disabled(missingRequired || isSubmitting)
            } footer: {
                if missingRequired {
                    Text("Please answer all required questions (marked *).")
                }
            }
        }
        .navigationTitle(questionnaire.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        // Drop answers for questions that are no longer visible (stale conditionals).
        let visibleIDs = Set(visibleQuestions.map(\.id))
        let final = answers.filter { visibleIDs.contains($0.key) }
        isSubmitting = true
        Task {
            await onSubmit(final)
            isSubmitting = false
            dismiss()
        }
    }

    // MARK: Controls

    @ViewBuilder
    private func control(for q: BaselineQuestion) -> some View {
        switch q.type {
        case .boolean:
            booleanControl(q.id)
        case .singleChoice(let options):
            singleChoiceControl(q.id, options: options)
        case .multiChoice(let options):
            multiChoiceControl(q.id, options: options)
        case .scale(let min, let max, let minLabel, let maxLabel):
            scaleControl(q.id, min: min, max: max, minLabel: minLabel, maxLabel: maxLabel)
        case .number(_, _, let unit):
            numberControl(q.id, unit: unit)
        case .text:
            textControl(q.id)
        }
    }

    private func booleanControl(_ id: String) -> some View {
        let current: Bool? = { if case .bool(let b)? = answers[id] { return b }; return nil }()
        return HStack(spacing: 10) {
            ForEach([true, false], id: \.self) { value in
                Button {
                    answers[id] = .bool(value)
                } label: {
                    Text(value ? "Yes" : "No")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(current == value ? Color.blue : Color.gray.opacity(0.12))
                        .foregroundStyle(current == value ? .white : .primary)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func singleChoiceControl(_ id: String, options: [String]) -> some View {
        let current: String? = { if case .single(let s)? = answers[id] { return s }; return nil }()
        return Menu {
            ForEach(options, id: \.self) { opt in
                Button(opt) { answers[id] = .single(opt) }
            }
        } label: {
            HStack {
                Text(current ?? "Select")
                    .foregroundStyle(current == nil ? .secondary : .primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
        }
    }

    private func multiChoiceControl(_ id: String, options: [String]) -> some View {
        let selected: Set<String> = { if case .multi(let a)? = answers[id] { return Set(a) }; return [] }()
        return VStack(spacing: 0) {
            ForEach(options, id: \.self) { opt in
                Button {
                    var set = selected
                    if set.contains(opt) { set.remove(opt) } else { set.insert(opt) }
                    answers[id] = set.isEmpty ? nil : .multi(Array(set))
                } label: {
                    HStack {
                        Image(systemName: selected.contains(opt) ? "checkmark.square.fill" : "square")
                            .foregroundStyle(selected.contains(opt) ? .blue : .secondary)
                        Text(opt).foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scaleControl(_ id: String, min: Int, max: Int, minLabel: String, maxLabel: String) -> some View {
        let currentInt: Int? = { if case .scale(let i)? = answers[id] { return i }; return nil }()
        let binding = Binding<Double>(
            get: { Double(currentInt ?? min) },
            set: { answers[id] = .scale(Int($0.rounded())) }
        )
        return VStack(spacing: 4) {
            HStack {
                Text(minLabel).font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text(currentInt.map(String.init) ?? "—").font(.headline)
                Spacer()
                Text(maxLabel).font(.caption2).foregroundStyle(.secondary)
            }
            Slider(value: binding, in: Double(min)...Double(max), step: 1)
        }
    }

    private func numberControl(_ id: String, unit: String?) -> some View {
        let binding = Binding<String>(
            get: {
                if case .number(let d)? = answers[id] {
                    return d == d.rounded() ? String(Int(d)) : String(d)
                }
                return ""
            },
            set: { str in
                let trimmed = str.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { answers.removeValue(forKey: id) }
                else if let d = Double(trimmed) { answers[id] = .number(d) }
            }
        )
        return HStack {
            TextField("Enter a number", text: binding)
                .keyboardType(.decimalPad)
            if let unit { Text(unit).foregroundStyle(.secondary) }
        }
    }

    private func textControl(_ id: String) -> some View {
        let binding = Binding<String>(
            get: { if case .text(let s)? = answers[id] { return s }; return "" },
            set: { str in
                if str.isEmpty { answers.removeValue(forKey: id) } else { answers[id] = .text(str) }
            }
        )
        return TextField("Your answer", text: binding, axis: .vertical)
            .lineLimit(1...4)
    }
}
