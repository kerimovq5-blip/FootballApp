//
//  AppConfig.swift
//  FootballApp
//

import Foundation

enum AppConfig {

    /// Açar `Secrets.swift`-dən gəlir. Dəyişdirilməyibsə boş qaytarılır.
    static var apiKey: String {
        let key = Secrets.apiKey
        return key.hasPrefix("BURAYA") ? "" : key
    }

    static var hasAPIKey: Bool { !apiKey.isEmpty }
}
