import foundation

class SurveySessionManager {
    func sendToServer(_ survey: SurveySession) async throws{
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(survey)
    }



}