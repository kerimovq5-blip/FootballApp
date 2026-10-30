//
//  APIConfig.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

//
//  APIConfig.swift
//  FootballApp
//

import Foundation

enum APIConfig {

    static let baseURL = "https://v3.football.api-sports.io"

    /// Pulsuz plan yalnız köhnə mövsümləri açır (API xəta mesajında 2022–2024 yazdı).
    /// Ödənişli plana keçəndə bunu 2026 et. (Standing dilimində istifadə olunacaq.)
    static let season = 2024

    /// Home-un göstərdiyi tarix ("yyyy-MM-dd"). nil olsa real bu gün göstərilir (ödənişli plan).
    /// 2024-10-19: Premier League-in 8-ci turu, şənbə günü oyunlar var.
    static let demoDate: String? = "2024-10-19"

    /// Home-da göstərilən liqalar (API-Football id-ləri), bu sıra ilə.
    /// 419: Azərbaycan Premyer Liqası (id-ni `leagues?country=Azerbaijan` cavabı ilə təsdiqlə).
    static let homeLeagueIDs = [39, 140, 135, 78, 61, 203, 419, 2, 3]

    /// Liqa loqosu. Şəkillər API limitinə sayılmır.
    static func leagueLogoURL(id: Int) -> String {
        "https://media.api-sports.io/football/leagues/\(id).png"
    }

    /// Bu günə nisbətən verilən gün ("yyyy-MM-dd"): -1 dünən, 0 bu gün, 1 sabah.
    /// Pulsuz plan yalnız bu üç gün üçün oyun verir.

    static let availableDayOffsets = [-1, 0, 1]
    
    static func date(dayOffset: Int) -> String {
        let date = Calendar.current.date(
            byAdding: .day,
            value: dayOffset,
            to: Date()
        ) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
