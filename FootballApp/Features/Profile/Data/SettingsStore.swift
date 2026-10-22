//
//  SettingsStore.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

protocol SettingsStoring: AnyObject {
    var notificationsEnabled: Bool { get set }
    var goalAlertsEnabled: Bool { get set }
}

final class UserDefaultsSettingsStore: SettingsStoring {

    private enum Key {
        static let notifications = "settings.notifications"
        static let goalAlerts = "settings.goalAlerts"
    }

    private let defaults = UserDefaults.standard

    var notificationsEnabled: Bool {
        get { defaults.object(forKey: Key.notifications) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.notifications) }
    }

    var goalAlertsEnabled: Bool {
        get { defaults.object(forKey: Key.goalAlerts) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.goalAlerts) }
    }
}
