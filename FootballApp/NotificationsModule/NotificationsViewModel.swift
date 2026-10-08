//
//  NotificationsViewModel.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

final class NotificationsViewModel {

    /// Data yenilənəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?

    private(set) var groups: [MatchNotificationGroup] = []

    private let provider: MatchNotificationProviding
    private let subscriptions: MatchSubscriptionStoring

    init(provider: MatchNotificationProviding = MockMatchNotificationService(),
         subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
        self.provider = provider
        self.subscriptions = subscriptions
    }

    /// Yalnız bildirişi açılmış oyunların bildirişlərini yükləyir.
    func load() {
        provider.fetchNotifications(matchIDs: subscriptions.subscribedMatchIDs) { [weak self] groups in
            self?.groups = groups
            self?.onChange?()
        }
    }
}
