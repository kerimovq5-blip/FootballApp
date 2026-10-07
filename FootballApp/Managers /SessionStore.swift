//
//  SessionStore.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

protocol SessionStore {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var isLoggedIn: Bool? { get }
    
    func save(accessToken: String, refreshToken: String)
    func clear()
}

// UserDefaults üçün key adlarını saxlayan sadə struct
struct SessionKeys {
    let accessTokenKey: String
    let refreshTokenKey: String
    
    init(accessTokenKey: String = "access_token",
         refreshTokenKey: String = "refresh_token") {
        self.accessTokenKey = accessTokenKey
        self.refreshTokenKey = refreshTokenKey
    }
}

final class UserDefaultsSessionStore: SessionStore {
    
    private let keys: SessionKeys
    private let defaults: UserDefaults

    init(keys: SessionKeys = SessionKeys(), defaults: UserDefaults = .standard) {
        self.keys = keys
        self.defaults = defaults
    }

    var accessToken: String? {
        get { defaults.string(forKey: keys.accessTokenKey) }
        set { defaults.setValue(newValue, forKey: keys.accessTokenKey) }
    }

    var refreshToken: String? {
        get { defaults.string(forKey: keys.refreshTokenKey) }
        set { defaults.setValue(newValue, forKey: keys.refreshTokenKey) }
    }

    var isLoggedIn: Bool? {
        accessToken != nil
    }

    func save(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clear() {
        defaults.removeObject(forKey: keys.accessTokenKey)
        defaults.removeObject(forKey: keys.refreshTokenKey)
    }
}
