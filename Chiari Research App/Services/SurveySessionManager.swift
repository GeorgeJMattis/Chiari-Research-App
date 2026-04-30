import Foundation

class SurveySessionManager {
    func sendToServer(_ survey: SurveySession) async throws {
        let jsonEncoder = JSONEncoder()
        _ = try jsonEncoder.encode(survey)
    }
}
