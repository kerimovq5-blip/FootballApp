//
//  SettingsStore.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

final class UserDefaultsSettingsStore: SettingsStoring {

    private enum Key {
        static let notifications = "settings.notifications"
    }

    private let defaults = UserDefaults.standard

    var notificationsEnabled: Bool {
        get { defaults.object(forKey: Key.notifications) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.notifications) }
    }
}
