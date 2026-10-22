//
//  ActivityStore.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

struct ActivityItem: Codable {
    let matchID: Int
    /// "Arsenal vs Aston Villa"
    let title: String
    /// Liqanın adı
    let subtitle: String
    let date: Date
}

protocol ActivityStoring: AnyObject {
    func record(matchID: Int, title: String, subtitle: String)
    func recent() -> [ActivityItem]
    func clear()
}

/// Son baxılan oyunlar. Match detail bunu yazır, profil ekranı oxuyur.
final class UserDefaultsActivityStore: ActivityStoring {

    static let shared = UserDefaultsActivityStore()

    private let key = "activity.recentMatches"
    private let limit = 20
    private let defaults = UserDefaults.standard

    private init() {}

    func record(matchID: Int, title: String, subtitle: String) {
        // Eyni oyun təkrar açılsa sıranın əvvəlinə keçir.
        var items = recent().filter { $0.matchID != matchID }
        items.insert(ActivityItem(matchID: matchID, title: title, subtitle: subtitle, date: Date()), at: 0)
        save(Array(items.prefix(limit)))
    }

    func recent() -> [ActivityItem] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([ActivityItem].self, from: data) else { return [] }
        return items
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    private func save(_ items: [ActivityItem]) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
}
