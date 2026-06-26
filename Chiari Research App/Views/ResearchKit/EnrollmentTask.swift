//
//  EnrollmentTask.swift
//  Chiari Research App
//
//  Builds the ResearchKit enrollment task: an informed-consent sequence
//  followed by the baseline symptom survey. Compiles only when the
//  RESEARCHKIT_ENABLED flag is set (i.e. once the ResearchKit package is added
//  to the project in Xcode).
//
//  The consent copy below is placeholder text — replace each section's
//  summary/content with your IRB-approved language before launch.
//

#if RESEARCHKIT_ENABLED
import ResearchKit

enum EnrollmentTask {
    static let taskID = "enrollment"
    static let symptomsStepID = "baselineSymptoms"

    /// The Chiari baseline symptom list (mirrors the former onboarding screen).
    static let symptoms = [
        "Headaches", "Fatigue", "Dizziness", "Neck Pain",
        "Brain Fog", "Vision Changes", "Balance Issues"
    ]

    static func make() -> ORKOrderedTask {
        var steps: [ORKStep] = []

        // MARK: Consent document
        let document = ORKConsentDocument()
        document.title = "Chiari Research Study"

        let overview = ORKConsentSection(type: .overview)
        overview.summary = "You are invited to join an anonymous research study on Chiari malformation."
        overview.content = "This study collects environmental sensor data and daily symptom reports to help researchers understand how factors like barometric pressure relate to symptoms. Replace this with your IRB-approved overview."

        let dataGathering = ORKConsentSection(type: .dataGathering)
        dataGathering.summary = "We collect sensor and symptom data."
        dataGathering.content = "The app records barometric pressure and ambient light from your device, plus the daily symptom surveys you complete. No name, email, or location is collected."

        let privacy = ORKConsentSection(type: .privacy)
        privacy.summary = "Your participation is anonymous."
        privacy.content = "Data is stored against a random identifier, not your identity. Describe your data handling and retention here."

        let dataUse = ORKConsentSection(type: .dataUse)
        dataUse.summary = "How your data is used."
        dataUse.content = "Data is used solely for this research study. Describe sharing/usage policy here."

        let timeCommitment = ORKConsentSection(type: .timeCommitment)
        timeCommitment.summary = "About a few minutes per day."
        timeCommitment.content = "You'll be asked to complete short symptom surveys up to four times a day for the duration of the study."

        let withdrawing = ORKConsentSection(type: .withdrawing)
        withdrawing.summary = "You may leave at any time."
        withdrawing.content = "You can leave the study from the Profile screen. Because participation is anonymous, leaving disconnects this device from its collected data."

        document.sections = [overview, dataGathering, privacy, dataUse, timeCommitment, withdrawing]

        // Anonymous study: capture agreement but no name.
        let signature = ORKConsentSignature(
            forPersonWithTitle: nil,
            dateFormatString: nil,
            identifier: "consentSignature"
        )
        signature.requiresName = false
        document.addSignature(signature)

        let visualConsent = ORKVisualConsentStep(identifier: "visualConsent", document: document)
        steps.append(visualConsent)

        let reviewStep = ORKConsentReviewStep(identifier: "consentReview", signature: signature, in: document)
        reviewStep.text = "Please review the study information."
        reviewStep.reasonForConsent = "By agreeing, you consent to participate in this anonymous research study."
        steps.append(reviewStep)

        // MARK: Baseline symptom survey
        let choices = symptoms.map { ORKTextChoice(text: $0, value: $0 as NSString) }
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: choices)
        let symptomStep = ORKQuestionStep(
            identifier: symptomsStepID,
            title: "Baseline Symptoms",
            question: "Select your most significant symptoms. Headaches should be included.",
            answer: answerFormat
        )
        symptomStep.isOptional = false
        steps.append(symptomStep)
        // NOTE: ResearchKit's plain multiple-choice does not enforce "Headaches
        // required" or a max of 5. If you need that, validate in the completion
        // handler or build a navigable task with predicates.

        let completion = ORKCompletionStep(identifier: "completion")
        completion.title = "You're enrolled"
        completion.text = "Thank you for joining the Chiari research study."
        steps.append(completion)

        return ORKOrderedTask(identifier: taskID, steps: steps)
    }
}
#endif
