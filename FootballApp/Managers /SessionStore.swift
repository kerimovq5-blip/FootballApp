//
//  SessionStore.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

protocol SessionStoring {
    var token: String? { get }
    func save(token: String)
    func clear()
}

/// Müvəqqəti implementasiya. UserDefaults şifrələnmir, ona görə real token gələndən əvvəl
/// bu tipin yerinə Keychain istifadə edən implementasiya yazılmalıdır (protokol eyni qalır).
struct UserDefaultsSessionStore: SessionStoring {
    private let key = "session.token"
    private let defaults = UserDefaults.standard

    var token: String? {
        defaults.string(forKey: key)
    }

    func save(token: String) {
        defaults.set(token, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
