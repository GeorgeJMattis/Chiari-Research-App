protocol SurveyRepository {
    func saveSurveySession(_ session: SurveySession) async throws
    func fetchSessions(forUID uid: String, from: Date, to: Date) async throws -> [SurveySession]
    func fetchSession(forUID uid: String, date: Date, slot: SurveySlot) async throws -> SurveySession?
}
