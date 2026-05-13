import Foundation
import UserNotifications

class SurveyScheduler {
    static let shared = SurveyScheduler()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Cancels all existing survey notifications and schedules 4 daily ones
    /// based on the device's local calendar (repeating every day).
    func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()
        // Remove old survey notifications before rescheduling
        let identifiers = SurveySlot.allCases.map { "survey_\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        for slot in SurveySlot.allCases {
            let content = UNMutableNotificationContent()
            content.title = "\(slot.displayName) check-in"
            content.body = "How are you feeling? Tap to log your symptoms."
            content.sound = .default

            var components = DateComponents()
            components.hour = slot.hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )
            let request = UNNotificationRequest(
                identifier: "survey_\(slot.rawValue)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
}
