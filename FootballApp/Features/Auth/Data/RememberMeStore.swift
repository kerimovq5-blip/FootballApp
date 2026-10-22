//
//  RememberMeStore.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//

//
//  RememberMeStore.swift
//  FootballApp
//

import Foundation

enum RememberMeStore {

    private static let enabledKey = "rememberMe.isEnabled"
    private static let emailKey = "rememberMe.email"
    private static var defaults: UserDefaults { .standard }

    static var isEnabled: Bool { defaults.bool(forKey: enabledKey) }
    static var savedEmail: String? { defaults.string(forKey: emailKey) }

    /// Seçilibsə email də saxlanır, seçilməyibsə silinir.
    static func update(isEnabled: Bool, email: String) {
        defaults.set(isEnabled, forKey: enabledKey)
        if isEnabled {
            defaults.set(email, forKey: emailKey)
        } else {
            defaults.removeObject(forKey: emailKey)
        }
    }
}
