//
//  MatchReminderStore.swift
//  FootballApp
//

import Foundation

/// Xatırlatmalar UserDefaults-da JSON kimi saxlanılır.
final class UserDefaultsMatchReminderStore: MatchReminderStoring {

    static let shared = UserDefaultsMatchReminderStore()

    private let key = "notifications.reminders"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var reminders: [MatchReminder] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([MatchReminder].self, from: data)) ?? []
    }

    func save(_ reminder: MatchReminder) {
        var items = reminders.filter { $0.matchID != reminder.matchID }
        items.append(reminder)
        write(items)
    }

    func remove(matchID: Int) {
        write(reminders.filter { $0.matchID != matchID })
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    private func write(_ items: [MatchReminder]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
