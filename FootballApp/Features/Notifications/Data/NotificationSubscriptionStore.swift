//
//  NotificationSubscriptionStore.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

/// Bildirişi açılmış oyunların id-ləri. Home-dakı zəng düyməsi yazır, Notifications ekranı oxuyur.
final class UserDefaultsMatchSubscriptionStore: MatchSubscriptionStoring {

    static let shared = UserDefaultsMatchSubscriptionStore()

    private let key = "notifications.subscribedMatches"
    private let defaults = UserDefaults.standard

    private init() {}

    var subscribedMatchIDs: Set<Int> {
        Set(defaults.array(forKey: key) as? [Int] ?? [])
    }

    func isSubscribed(_ matchID: Int) -> Bool {
        subscribedMatchIDs.contains(matchID)
    }

    @discardableResult
    func toggle(_ matchID: Int) -> Bool {
        var ids = subscribedMatchIDs
        let isNowSubscribed: Bool
        if ids.contains(matchID) {
            ids.remove(matchID)
            isNowSubscribed = false
        } else {
            ids.insert(matchID)
            isNowSubscribed = true
        }
        defaults.set(ids.sorted(), forKey: key)
        return isNowSubscribed
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
