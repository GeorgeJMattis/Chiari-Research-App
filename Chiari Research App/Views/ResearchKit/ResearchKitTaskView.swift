//
//  ResearchKitTaskView.swift
//  Chiari Research App
//
//  SwiftUI bridge for the UIKit-based ORKTaskViewController (official
//  ResearchKit). Presents an ORKOrderedTask and reports the outcome:
//   - onComplete(symptoms): the participant finished the task (consented +
//     answered the baseline survey). `symptoms` are the selected choices.
//   - onCancel(): the participant cancelled or declined consent.
//
//  Compiles only when RESEARCHKIT_ENABLED is set.
//

#if RESEARCHKIT_ENABLED
import SwiftUI
// ORKTaskViewController + delegate live in ResearchKitUI; the task/result model
// types in ResearchKit. Add both products to the target in Xcode.
import ResearchKit
import ResearchKitUI

struct ResearchKitTaskView: UIViewControllerRepresentable {
    let task: ORKOrderedTask
    let onComplete: (_ symptoms: [String]) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = context.coordinator
        return taskViewController
    }

    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {}

    final class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        let parent: ResearchKitTaskView

        init(_ parent: ResearchKitTaskView) {
            self.parent = parent
        }

        func taskViewController(_ taskViewController: ORKTaskViewController,
                                didFinishWith reason: ORKTaskViewControllerFinishReason,
                                error: Error?) {
            switch reason {
            case .completed:
                parent.onComplete(Self.selectedSymptoms(from: taskViewController.result))
            default:
                // .discarded, .failed, .saved → treat as not enrolled.
                parent.onCancel()
            }
        }

        private static func selectedSymptoms(from taskResult: ORKTaskResult) -> [String] {
            guard
                let stepResult = taskResult.stepResult(forStepIdentifier: EnrollmentTask.symptomsStepID),
                let choiceResult = stepResult.results?.first as? ORKChoiceQuestionResult,
                let answers = choiceResult.choiceAnswers
            else { return [] }
            return answers.compactMap { $0 as? String }
        }
    }
}
#endif
