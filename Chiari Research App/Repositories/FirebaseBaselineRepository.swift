//
//  FirebaseBaselineRepository.swift
//  Chiari Research App
//
//  Persists baseline questionnaire responses to Firestore. Mirrors the
//  hand-rolled dictionary (de)serialization used by FirebaseSurveyRepository.
//  Ownership lives in the `uid` field (see firestore.rules).
//

import Foundation
import FirebaseFirestore

class FirebaseBaselineRepository: BaselineRepository {
    private let db = Firestore.firestore()
    private let collection = "baselineResponses"

    func fetchResponses(forUID uid: String) async throws -> [String: BaselineResponse] {
        let snapshot = try await db.collection(collection)
            .whereField("uid", isEqualTo: uid)
            .getDocuments()

        var byQuestionnaire: [String: BaselineResponse] = [:]
        for doc in snapshot.documents {
            if let response = decode(doc) {
                byQuestionnaire[response.questionnaireID] = response
            }
        }
        return byQuestionnaire
    }

    func saveResponse(_ response: BaselineResponse) async throws {
        var answersData: [String: [String: Any]] = [:]
        for (questionID, answer) in response.answers {
            answersData[questionID] = answer.toFirestore()
        }

        var data: [String: Any] = [
            "uid": response.uid,
            "questionnaireID": response.questionnaireID,
            "answers": answersData,
            "version": response.version,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let completedAt = response.completedAt {
            data["completedAt"] = completedAt
        }

        let docID = BaselineResponse.makeID(uid: response.uid, questionnaireID: response.questionnaireID)
        try await db.collection(collection).document(docID).setData(data)
    }

    private func decode(_ doc: QueryDocumentSnapshot) -> BaselineResponse? {
        let data = doc.data()
        guard
            let uid = data["uid"] as? String,
            let questionnaireID = data["questionnaireID"] as? String
        else { return nil }

        var answers: [String: BaselineAnswer] = [:]
        if let rawAnswers = data["answers"] as? [String: [String: Any]] {
            for (questionID, dict) in rawAnswers {
                if let answer = BaselineAnswer(fromFirestore: dict) {
                    answers[questionID] = answer
                }
            }
        }

        return BaselineResponse(
            uid: uid,
            questionnaireID: questionnaireID,
            answers: answers,
            version: data["version"] as? Int ?? 1,
            completedAt: (data["completedAt"] as? Timestamp)?.dateValue()
        )
    }
}
