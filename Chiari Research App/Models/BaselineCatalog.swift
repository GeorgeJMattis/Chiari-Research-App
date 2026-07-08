//
//  BaselineCatalog.swift
//  Chiari Research App
//
//  The baseline questionnaire content, transcribed from the anonymous-safe
//  portions of the Chiari 1000 registry (Background & Medical History, Parts
//  1–6). Identity fields (name/email/address, exact DOB, surgeon name) are
//  deliberately omitted; ages are collected in years, surgery dates as MM/YYYY.
//
//  This is content-as-data: BaselineFormView renders any questionnaire here
//  generically. Bump a questionnaire's `version` when its questions change.
//

import Foundation

enum BaselineCatalog {
    static let all: [BaselineQuestionnaire] = [
        generalBackground,
        chiariDiagnosis,
        additionalDiagnoses,
        symptoms,
        surgicalHistory,
        qualityOfLife
    ]

    static func questionnaire(id: String) -> BaselineQuestionnaire? {
        all.first { $0.id == id }
    }

    // Shared option lists
    private static let raceOptions = [
        "Native American/Alaska Native", "Asian", "Black or African American",
        "Native Hawaiian or other Pacific Islander", "White"
    ]
    private static let ethnicityOptions = ["Not Hispanic or Latino", "Hispanic or Latino"]
    private static let severityOptions = ["Mild", "Moderate", "Severe"]
    private static let changeOptions = [
        "Improved significantly", "Improved slightly", "No change",
        "Worsened slightly", "Worsened significantly"
    ]
    private static func yes(_ id: String) -> ShowCondition { ShowCondition(questionID: id, equals: ["Yes"]) }

    // MARK: - 1. General Background

    static let generalBackground = BaselineQuestionnaire(
        id: "general_background",
        title: "General Background",
        subtitle: "Demographics · about 5 min",
        systemImage: "person.text.rectangle",
        version: 1,
        questions: [
            BaselineQuestion(id: "gender", prompt: "Gender", type: .singleChoice(["Female", "Male"])),
            BaselineQuestion(id: "age", prompt: "What is your age, in years?", type: .number(min: 0, max: 120, unit: "years")),
            BaselineQuestion(id: "heightInches", prompt: "Height", type: .number(min: 0, max: 96, unit: "in"), isOptional: true),
            BaselineQuestion(id: "weightPounds", prompt: "Weight", type: .number(min: 0, max: 1000, unit: "lb"), isOptional: true),
            BaselineQuestion(id: "race", prompt: "Race (check all that apply)", type: .multiChoice(raceOptions)),
            BaselineQuestion(id: "ethnicity", prompt: "Ethnicity", type: .singleChoice(ethnicityOptions)),
            BaselineQuestion(id: "birthCountry", prompt: "What country were you born in?", type: .singleChoice(Geography.countries)),
            BaselineQuestion(
                id: "education",
                prompt: "Highest degree or level of school completed",
                type: .singleChoice([
                    "No schooling completed", "Nursery school to 8th grade",
                    "Some high school, no diploma", "High school graduate",
                    "Diploma or the equivalent (e.g. GED)", "Some college credit, no degree",
                    "Trade/technical/vocational training", "Associate degree",
                    "Bachelor's degree", "Master's degree", "Professional degree", "Doctorate degree"
                ])
            ),
            BaselineQuestion(
                id: "employment",
                prompt: "Employment status (check all that apply)",
                type: .multiChoice([
                    "Employed for wages", "Self-employed", "Out of work and looking for work",
                    "Out of work but not currently looking for work", "A homemaker", "A student",
                    "Military", "Retired", "Unable to work", "Too young for employment"
                ])
            ),
            BaselineQuestion(id: "motherRaceKnown", prompt: "Is your biological mother's race known?", type: .boolean, isOptional: true),
            BaselineQuestion(id: "motherRace", prompt: "Mother's race (check all that apply)", type: .multiChoice(raceOptions), isOptional: true, condition: yes("motherRaceKnown")),
            BaselineQuestion(id: "motherEthnicity", prompt: "Mother's ethnicity", type: .singleChoice(ethnicityOptions), isOptional: true, condition: yes("motherRaceKnown")),
            BaselineQuestion(id: "fatherRaceKnown", prompt: "Is your biological father's race known?", type: .boolean, isOptional: true),
            BaselineQuestion(id: "fatherRace", prompt: "Father's race (check all that apply)", type: .multiChoice(raceOptions), isOptional: true, condition: yes("fatherRaceKnown")),
            BaselineQuestion(id: "fatherEthnicity", prompt: "Father's ethnicity", type: .singleChoice(ethnicityOptions), isOptional: true, condition: yes("fatherRaceKnown"))
        ]
    )

    // MARK: - 2. Chiari Diagnosis

    static let chiariDiagnosis = BaselineQuestionnaire(
        id: "chiari_diagnosis",
        title: "Chiari Diagnosis",
        subtitle: "Diagnosis history · about 5 min",
        systemImage: "brain.head.profile",
        version: 1,
        questions: [
            BaselineQuestion(id: "hadMRI", prompt: "Have you had an MRI which showed a Chiari malformation or herniation of the cerebellar tonsils?", type: .boolean),
            BaselineQuestion(id: "hasMRICopy", prompt: "Do you have a copy of your MRI (prior to any Chiari surgery) on a disc or hard drive?", type: .boolean, isOptional: true, condition: yes("hadMRI")),
            BaselineQuestion(id: "physicianDiagnosed", prompt: "Has a physician diagnosed you with Chiari malformation?", type: .boolean),
            BaselineQuestion(id: "chiariType", prompt: "Please indicate the type", type: .singleChoice(["Chiari I", "Chiari II", "Chiari III", "Chiari IV", "Unknown"]), condition: yes("physicianDiagnosed")),
            BaselineQuestion(id: "ageAtDiagnosis", prompt: "What was your age, in years, when you were diagnosed?", type: .number(min: 0, max: 120, unit: "years"), condition: yes("physicianDiagnosed")),
            BaselineQuestion(id: "diagnosisContext", prompt: "Were you actively seeking a diagnosis, or was it found incidentally?", type: .singleChoice(["Actively Seeking Diagnosis", "Found Incidentally"]), condition: yes("physicianDiagnosed")),
            BaselineQuestion(id: "monthsSearching", prompt: "Approximately how many months had you been searching for a diagnosis?", type: .number(min: 0, max: 600, unit: "months"), isOptional: true, condition: ShowCondition(questionID: "diagnosisContext", equals: ["Actively Seeking Diagnosis"])),
            BaselineQuestion(id: "doctorsSeen", prompt: "How many different doctors did you see searching for a diagnosis?", type: .number(min: 0, max: 100, unit: nil), isOptional: true, condition: ShowCondition(questionID: "diagnosisContext", equals: ["Actively Seeking Diagnosis"])),
            BaselineQuestion(id: "reasonForImaging", prompt: "What was the reason for getting the imaging test that showed Chiari?", type: .text, isOptional: true, condition: ShowCondition(questionID: "diagnosisContext", equals: ["Found Incidentally"])),
            BaselineQuestion(id: "toldSymptomsMental", prompt: "Before being diagnosed, were you ever told your symptoms were in your head (mental), due to stress/anxiety, or depression?", type: .boolean),
            BaselineQuestion(id: "toldNotRelated", prompt: "Has a physician told you that, while you have Chiari, your symptoms were not related to Chiari?", type: .boolean),
            BaselineQuestion(id: "otherPhysicianRelated", prompt: "Did a different physician tell you your symptoms were likely due to Chiari?", type: .boolean, isOptional: true, condition: yes("toldNotRelated")),
            BaselineQuestion(id: "immediateFamilyDiagnosed", prompt: "Has an immediate family member (mother, father, brother, sister, child) been diagnosed with Chiari?", type: .boolean),
            BaselineQuestion(id: "immediateFamilyCount", prompt: "How many immediate family members have been diagnosed?", type: .number(min: 0, max: 50, unit: nil), condition: yes("immediateFamilyDiagnosed")),
            BaselineQuestion(id: "extendedFamilyDiagnosed", prompt: "Has an extended family member (grandparent, aunt, uncle, cousin, etc.) been diagnosed with Chiari?", type: .boolean),
            BaselineQuestion(id: "extendedFamilyCount", prompt: "How many extended family members have been diagnosed?", type: .number(min: 0, max: 50, unit: nil), condition: yes("extendedFamilyDiagnosed"))
        ]
    )

    // MARK: - 3. Additional Diagnoses

    static let additionalDiagnoses = BaselineQuestionnaire(
        id: "additional_diagnoses",
        title: "Additional Diagnoses",
        subtitle: "Other conditions · about 5 min",
        systemImage: "list.clipboard",
        version: 1,
        questions: [
            BaselineQuestion(id: "commonlyAssociated", prompt: "Conditions commonly associated with Chiari (check all that apply)", type: .multiChoice([
                "Syringomyelia", "Hydrocephalus", "Basilar invagination/impression", "Pseudotumor cerebri",
                "Tethered Cord Syndrome", "Myelomeningocele (spina bifida)", "Cervical instability",
                "Craniosynostosis", "None of the above"
            ])),
            BaselineQuestion(id: "spinalDefects", prompt: "Spinal defects (check all that apply)", type: .multiChoice([
                "Atlantoaxial assimilation", "Klippel-Feil syndrome", "Scoliosis", "None of the above"
            ])),
            BaselineQuestion(id: "autoimmune", prompt: "Autoimmune conditions (check all that apply)", type: .multiChoice([
                "Chronic fatigue syndrome", "Multiple sclerosis", "Lupus", "Reynaud's",
                "Meniere's disease", "Hyperimmunoglobin E syndrome", "None of the above"
            ])),
            BaselineQuestion(id: "cutaneous", prompt: "Cutaneous disorders (check all that apply)", type: .multiChoice([
                "Neurofibromatosis type I", "None of the above"
            ])),
            BaselineQuestion(id: "connectiveTissue", prompt: "Connective tissue disorders (check all that apply)", type: .multiChoice([
                "Ehlers-Danlos syndrome", "Marfan syndrome", "MASS syndrome", "None of the above"
            ])),
            BaselineQuestion(id: "endocrine", prompt: "Endocrine diseases (check all that apply)", type: .multiChoice([
                "Growth Hormone deficiency", "Empty sella syndrome", "Abnormal pituitary", "None of the above"
            ])),
            BaselineQuestion(id: "otherConditions", prompt: "Other conditions (check all that apply)", type: .multiChoice([
                "Migraine headaches", "Fibromyalgia", "Cystic fibrosis", "Paget disease",
                "Achondroplasia", "Chromosome alterations", "None of the above"
            ])),
            BaselineQuestion(id: "anxietyDisorder", prompt: "Have you been diagnosed with an anxiety disorder?", type: .boolean),
            BaselineQuestion(id: "personalityDisorder", prompt: "Have you been diagnosed with a personality disorder?", type: .boolean),
            BaselineQuestion(id: "learningDisorder", prompt: "Have you been diagnosed with a learning disorder?", type: .boolean),
            BaselineQuestion(id: "sleepApnea", prompt: "Have you been diagnosed with sleep apnea?", type: .boolean),
            BaselineQuestion(id: "sleepApneaType", prompt: "Type of sleep apnea", type: .singleChoice(["Central", "Obstructive", "Mixed"]), isOptional: true, condition: yes("sleepApnea")),
            BaselineQuestion(id: "bladderProblems", prompt: "Bladder problems", type: .boolean),
            BaselineQuestion(id: "bowelProblems", prompt: "Bowel problems", type: .boolean),
            BaselineQuestion(id: "faintingBlackouts", prompt: "Fainting / blackouts", type: .boolean),
            BaselineQuestion(id: "fatigue", prompt: "Fatigue", type: .boolean),
            BaselineQuestion(id: "hadStroke", prompt: "Have you ever had a stroke?", type: .boolean),
            BaselineQuestion(id: "hadBrainTumor", prompt: "Have you ever had a brain tumor or space-occupying lesion such as an arachnoid cyst?", type: .boolean),
            BaselineQuestion(id: "hadConcussion", prompt: "Have you ever suffered a concussion with internal bleeding?", type: .boolean),
            BaselineQuestion(id: "severityAtDiagnosis", prompt: "Overall severity of your symptoms at the time of diagnosis", type: .singleChoice(severityOptions))
        ]
    )

    // MARK: - 4. Symptoms

    static let symptoms = BaselineQuestionnaire(
        id: "symptoms",
        title: "Symptoms",
        subtitle: "Current symptoms · about 5 min",
        systemImage: "waveform.path.ecg",
        version: 1,
        questions: [
            BaselineQuestion(id: "symptomOnsetAge", prompt: "At what age, in years, did symptoms you attribute to Chiari first appear?", type: .number(min: 0, max: 120, unit: "years")),
            BaselineQuestion(id: "onsetConfidence", prompt: "How confident are you that this is when Chiari-related symptoms started?", type: .singleChoice(["Not very confident", "Somewhat confident", "Very confident"])),
            BaselineQuestion(id: "specificTrigger", prompt: "Do you remember a specific event which triggered your Chiari symptoms?", type: .boolean),
            BaselineQuestion(id: "triggerEvent", prompt: "What was the event?", type: .singleChoice(["Sports Injury", "Car Accident", "Fall", "Childbirth", "Surgery", "Illness", "Other"]), isOptional: true, condition: yes("specificTrigger")),
            BaselineQuestion(id: "firstSymptom", prompt: "What single symptom was most responsible for you to start looking for a diagnosis?", type: .text, isOptional: true),
            BaselineQuestion(id: "worstSymptom", prompt: "Before learning you had Chiari, what was your worst symptom?", type: .text, isOptional: true),
            BaselineQuestion(id: "worseningFactors", prompt: "Which factors make your symptoms worse? (check all that apply)", type: .multiChoice([
                "Physical Labor", "Household Chores", "Computer Work", "Reading",
                "Hot Weather", "Cold Weather", "Changes in the Weather", "Other"
            ]), isOptional: true),
            BaselineQuestion(id: "headaches", prompt: "Headaches", type: .boolean),
            BaselineQuestion(id: "pain", prompt: "Pain", type: .boolean),
            BaselineQuestion(id: "painLocations", prompt: "Pain locations (check all that apply)", type: .multiChoice([
                "Neck", "Arms", "Shoulders", "Hands", "Upper back", "Legs", "Middle back", "Feet", "Lower back", "Face", "Other"
            ]), condition: yes("pain")),
            BaselineQuestion(id: "numbness", prompt: "Numbness / tingling", type: .boolean),
            BaselineQuestion(id: "numbnessLocations", prompt: "Numbness / tingling locations (check all that apply)", type: .multiChoice([
                "Left Hand", "Right Hand", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Leg", "Right Leg", "Face", "Other"
            ]), condition: yes("numbness")),
            BaselineQuestion(id: "weakness", prompt: "Weakness in arms / hands / legs / feet", type: .boolean),
            BaselineQuestion(id: "weaknessLocations", prompt: "Weakness locations (check all that apply)", type: .multiChoice([
                "Left Hand", "Right Hand", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Leg", "Right Leg"
            ]), condition: yes("weakness")),
            BaselineQuestion(id: "earBalance", prompt: "Ear / balance issues (check all that apply)", type: .multiChoice([
                "Dizziness", "Vertigo", "Balance Problems", "Fullness in Ears", "Ringing in Ears (tinnitus)",
                "Ear pain", "Loss of hearing", "Sensitivity to Loud Noises", "None"
            ])),
            BaselineQuestion(id: "eyes", prompt: "Eyes (check all that apply)", type: .multiChoice([
                "Blurred vision", "Double vision", "Nystagmus", "Sensitivity to light", "Strabismus", "None"
            ])),
            BaselineQuestion(id: "troubleSleeping", prompt: "Trouble sleeping?", type: .boolean),
            BaselineQuestion(id: "sleepSeverity", prompt: "Sleep issue severity", type: .singleChoice(severityOptions), isOptional: true, condition: yes("troubleSleeping")),
            BaselineQuestion(id: "throatGI", prompt: "Throat / GI issues (check all that apply)", type: .multiChoice([
                "Trouble Swallowing", "Abnormal Gag Reflex", "Nausea", "Vomiting", "Hoarse Voice", "Ear popping when swallowing", "None"
            ])),
            BaselineQuestion(id: "cognitive", prompt: "Cognitive issues (check all that apply)", type: .multiChoice([
                "Memory Problems", "Brain Fog", "Trouble Finding the Right Word", "Problems with Decision Making", "Trouble Planning", "None"
            ])),
            BaselineQuestion(id: "depression", prompt: "Have you been diagnosed with depression?", type: .boolean),
            BaselineQuestion(id: "depressionSeverity", prompt: "Depression severity", type: .singleChoice(severityOptions), isOptional: true, condition: yes("depression"))
        ]
    )

    // MARK: - 5. Surgical History

    static let surgicalHistory = BaselineQuestionnaire(
        id: "surgical_history",
        title: "Surgical History",
        subtitle: "Chiari-related surgeries · about 5 min",
        systemImage: "cross.case",
        version: 1,
        questions: [
            BaselineQuestion(id: "hadChiariSurgery", prompt: "Have you undergone any type of Chiari-related surgery?", type: .boolean),
            BaselineQuestion(id: "decompression", prompt: "Chiari decompression / Posterior Fossa Decompression", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "multipleDecompressions", prompt: "Have you undergone more than one Chiari decompression and/or revision?", type: .boolean, isOptional: true, condition: yes("decompression")),
            BaselineQuestion(id: "decompressionCount", prompt: "How many decompressions/revisions have you undergone?", type: .number(min: 0, max: 50, unit: nil), isOptional: true, condition: yes("multipleDecompressions")),
            BaselineQuestion(id: "recentDecompressionDate", prompt: "Month and year of your MOST RECENT decompression/revision (MM/YYYY)", type: .text, isOptional: true, condition: yes("decompression")),
            BaselineQuestion(id: "shuntPlacement", prompt: "Shunt placement", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "cervicalFusion", prompt: "Cervical fusion / stabilization", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "transoralDecompression", prompt: "Transoral (through the mouth) decompression", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "tetheredCordRelease", prompt: "Tethered cord release", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "scoliosisCorrection", prompt: "Scoliosis correction", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "totalSurgeries", prompt: "How many total Chiari-related surgeries have you undergone?", type: .number(min: 0, max: 50, unit: nil), condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "surgeryImpact", prompt: "Overall, how did surgery impact your symptoms?", type: .singleChoice(changeOptions), condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "wouldDoAgain", prompt: "Knowing how you feel now, would you go through with the surgery again?", type: .boolean, condition: yes("hadChiariSurgery")),
            BaselineQuestion(id: "symptomsOverTime", prompt: "Overall, how have your symptoms changed over time since your diagnosis?", type: .singleChoice(changeOptions))
        ]
    )

    // MARK: - 6. Quality of Life

    static let qualityOfLife = BaselineQuestionnaire(
        id: "quality_of_life",
        title: "Quality of Life",
        subtitle: "How you're doing lately · about 3 min",
        systemImage: "heart.text.square",
        version: 1,
        questions: [
            BaselineQuestion(id: "overallHealth", prompt: "In general, how would you rate your overall health?", type: .singleChoice(["Excellent", "Very good", "Good", "Fair", "Poor"])),
            BaselineQuestion(id: "symptomsInterfereDaily", prompt: "In the past week, how much have your symptoms interfered with your daily activities?", type: .scale(min: 0, max: 10, minLabel: "Not at all", maxLabel: "Completely")),
            BaselineQuestion(id: "painInterference", prompt: "In the past week, how much has pain interfered with your daily activities?", type: .scale(min: 0, max: 10, minLabel: "Not at all", maxLabel: "Completely")),
            BaselineQuestion(id: "energyLevel", prompt: "In the past week, how would you rate your energy level?", type: .scale(min: 0, max: 10, minLabel: "No energy", maxLabel: "Full energy")),
            BaselineQuestion(id: "mood", prompt: "In the past week, how would you rate your overall mood?", type: .scale(min: 0, max: 10, minLabel: "Very low", maxLabel: "Very good")),
            BaselineQuestion(id: "socialLimitation", prompt: "How much do your symptoms limit your social activities?", type: .singleChoice(["Not at all", "Slightly", "Moderately", "Quite a bit", "Extremely"])),
            BaselineQuestion(id: "workSchoolImpact", prompt: "How much do your symptoms impact your ability to work or attend school?", type: .singleChoice(["No impact", "Mild", "Moderate", "Severe", "Unable to work/attend"])),
            BaselineQuestion(id: "generalNotes", prompt: "Anything else you'd like the research team to know?", type: .text, isOptional: true)
        ]
    )
}
