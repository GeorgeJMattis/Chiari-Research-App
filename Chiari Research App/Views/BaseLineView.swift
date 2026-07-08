//
//  BaselineView.swift
//  Chiari Research App
//
//  The Baseline tab: a list of one-time (but editable) background questionnaires
//  the participant can complete anytime during the study, with a progress card.
//

import SwiftUI

struct BaselineView: View {
    @ObservedObject var baselineViewModel: BaselineViewModel
    let uid: String

    var body: some View {
        NavigationStack {
            List {
                Section {
                    progressCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(baselineViewModel.questionnaires) { q in
                        NavigationLink {
                            BaselineFormView(
                                questionnaire: q,
                                existing: baselineViewModel.response(for: q.id)
                            ) { answers in
                                await baselineViewModel.submit(
                                    questionnaireID: q.id,
                                    answers: answers,
                                    uid: uid
                                )
                            }
                        } label: {
                            row(for: q)
                        }
                    }
                } header: {
                    Text("Questionnaires")
                } footer: {
                    Text("You can complete these in any order, anytime during the study. Answers can be updated later.")
                }
            }
            .navigationTitle("Baseline")
            .task { await baselineViewModel.load(uid: uid) }
            .refreshable { await baselineViewModel.load(uid: uid, force: true) }
        }
    }

    private var progressCard: some View {
        let done = baselineViewModel.completedCount
        let total = baselineViewModel.totalCount
        return VStack(alignment: .leading, spacing: 8) {
            Text("\(done) of \(total) completed")
                .font(.headline)
            ProgressView(value: Double(done), total: Double(max(total, 1)))
                .tint(.blue)
            Text(baselineViewModel.allCompleted
                 ? "All baseline questionnaires are complete — thank you!"
                 : "Complete your baseline questionnaires when you have a few minutes.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.gray.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.vertical, 4)
    }

    private func row(for q: BaselineQuestionnaire) -> some View {
        let completed = baselineViewModel.isCompleted(q.id)
        return HStack(spacing: 12) {
            Image(systemName: q.systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(q.title).font(.body)
                Text(q.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if completed {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BaselineView(baselineViewModel: BaselineViewModel(), uid: "preview")
}
