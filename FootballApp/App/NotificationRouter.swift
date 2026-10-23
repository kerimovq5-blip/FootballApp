//
//  NotificationRouter.swift
//  FootballApp
//
//  Bildirişlərin tətbiqlə əlaqəsi: tətbiq açıq olanda da banner göstərilir,
//  bildirişə toxunanda həmin oyunun səhifəsi açılır.
//

import UIKit
import UserNotifications

final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationRouter()

    /// Oyunu açan yer (AppCoordinator). Hələ hazır deyilsə id gözləyir.
    var onOpenMatch: ((Int) -> Void)? {
        didSet { deliverPendingMatch() }
    }

    private var pendingMatchID: Int?

    /// `AppDelegate` tətbiq açılanda çağırır.
    func register() {
        UNUserNotificationCenter.current().delegate = self
    }

    func openMatch(_ matchID: Int) {
        pendingMatchID = matchID
        deliverPendingMatch()
    }

    private func deliverPendingMatch() {
        guard let matchID = pendingMatchID, let onOpenMatch else { return }
        pendingMatchID = nil
        onOpenMatch(matchID)
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Tətbiq açıq olanda da bildiriş banner kimi görünsün.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification)
        async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        guard let matchID = userInfo[LocalNotificationScheduler.matchIDKey] as? Int else { return }
        await MainActor.run {
            NotificationRouter.shared.openMatch(matchID)
        }
    }
}
