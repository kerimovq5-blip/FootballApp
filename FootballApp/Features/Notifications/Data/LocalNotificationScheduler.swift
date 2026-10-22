//
//  LocalNotificationScheduler.swift
//  FootballApp
//
//  Xatırlatmalar telefonun özündə planlaşdırılır (local notification): server və ya
//  push sertifikatı lazım deyil, tətbiq bağlı olanda da gəlir.
//

import Foundation
import UserNotifications

struct LocalNotificationScheduler: MatchReminderScheduling {

    /// Bildirişə toxunanda hansı oyunun açılacağını bildirir (`NotificationRouter` oxuyur).
    static let matchIDKey = "matchID"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    func schedule(_ reminder: MatchReminder, at date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "\(reminder.home) – \(reminder.away)"
        content.subtitle = reminder.competition
        content.body = "Kick-off at \(Self.timeFormatter.string(from: reminder.kickoff)). Tap to follow the match."
        content.sound = .default
        content.userInfo = [Self.matchIDKey: reminder.matchID]

        let seconds = max(date.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        // Eyni id ilə əlavə olunan bildiriş köhnəsini əvəz edir.
        let request = UNNotificationRequest(identifier: Self.identifier(for: reminder.matchID),
                                            content: content,
                                            trigger: trigger)
        try await center.add(request)
    }

    func cancel(matchID: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: matchID)])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    private static func identifier(for matchID: Int) -> String {
        "match-reminder-\(matchID)"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}
