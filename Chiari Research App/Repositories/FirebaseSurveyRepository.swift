import Foundation
import FirebaseFirestore

class FirebaseSurveyRepository: SurveyRepository {
    private let db = Firestore.firestore()
    private let collection = "surveySessions"

    func saveSurveySession(_ session: SurveySession) async throws {
        var data: [String: Any] = [
            "id": session.id,
            "userId": session.userId,
            "scheduledDate": session.scheduledDate,
            "slot": session.slot.rawValue,
            "isCompleted": session.isCompleted
        ]
        if let r = session.responses {
            data["responses"] = [
                "hadHeadache": r.hadHeadache,
                "painLevel": r.painLevel
            ]
        }
        if let completedAt = session.completedAt {
            data["completedAt"] = completedAt
        }
        try await db.collection(collection).document(session.id).setData(data)
    }

    func fetchSessions(forUID uid: String, from: Date, to: Date) async throws -> [SurveySession] {
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: uid)
            .whereField("scheduledDate", isGreaterThanOrEqualTo: from)
            .whereField("scheduledDate", isLessThanOrEqualTo: to)
            .order(by: "scheduledDate", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { decode($0) }
    }

    func fetchSession(forUID uid: String, date: Date, slot: SurveySlot) async throws -> SurveySession? {
        let docID = SurveySession.makeID(userId: uid, date: date, slot: slot)
        let doc = try await db.collection(collection).document(docID).getDocument()
        guard doc.exists else { return nil }
        return decode(doc)
    }

    private func decode(_ doc: DocumentSnapshot) -> SurveySession? {
        guard let data = doc.data() else { return nil }
        guard
            let id = data["id"] as? String,
            let userId = data["userId"] as? String,
            let scheduledDate = (data["scheduledDate"] as? Timestamp)?.dateValue(),
            let slotRaw = data["slot"] as? String,
            let slot = SurveySlot(rawValue: slotRaw),
            let isCompleted = data["isCompleted"] as? Bool
        else { return nil }

        var responses: SurveyResponses?
        if let r = data["responses"] as? [String: Any],
           let hadHeadache = r["hadHeadache"] as? Bool,
           let painLevel = r["painLevel"] as? Double {
            responses = SurveyResponses(hadHeadache: hadHeadache, painLevel: painLevel)
        }
        let completedAt = (data["completedAt"] as? Timestamp)?.dateValue()

        return SurveySession(
            id: id,
            userId: userId,
            scheduledDate: scheduledDate,
            slot: slot,
            responses: responses,
            isCompleted: isCompleted,
            completedAt: completedAt
        )
    }
}
