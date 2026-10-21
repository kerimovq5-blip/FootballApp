//
//  APILeagueCatalog.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

//
//  APILeagueCatalog.swift
//  FootballApp
//

import Foundation

/// Tətbiqin göstərdiyi liqalar və API-Football id-ləri.
enum APILeagueCatalog {

    struct Entry {
        let id: Int
        let name: String
        let country: String
        let flag: String
        /// Mock və ya başqa mənbələrdə işlənən alternativ adlar.
        let aliases: [String]
    }

    static let entries: [Entry] = [
        Entry(id: 39, name: "Premier League", country: "England", flag: "🇬🇧", aliases: []),
        Entry(id: 140, name: "La Liga", country: "Spain", flag: "🇪🇸", aliases: ["LaLiga"]),
        Entry(id: 135, name: "Serie A", country: "Italy", flag: "🇮🇹", aliases: []),
        Entry(id: 78, name: "Bundesliga", country: "Germany", flag: "🇩🇪", aliases: []),
        Entry(id: 61, name: "Ligue 1", country: "France", flag: "🇫🇷", aliases: []),
        Entry(id: 203, name: "Süper Lig", country: "Turkey", flag: "🇹🇷", aliases: ["Trendyol Süper Lig"]),
        // id-ni `leagues?country=Azerbaijan` cavabı ilə təsdiqlə (418 ikinci divizion idi).
        Entry(id: 419, name: "Premyer Liqa", country: "Azerbaijan", flag: "🇦🇿",
              aliases: ["Azerbaijan Premier League", "Premyer Liqası"]),
        Entry(id: 2, name: "UEFA Champions League", country: "Europe", flag: "🇪🇺",
              aliases: ["Champions League"]),
        Entry(id: 3, name: "UEFA Europa League", country: "Europe", flag: "🇪🇺",
              aliases: ["Europa League"])
    ]

    /// Standing tabında göstərilən liqalar.
    static var leagues: [League] {
        entries.map {
            League(id: $0.id, name: $0.name, country: $0.country, flag: $0.flag, matches: [])
        }
    }

    /// Verilən liqanın API-Football id-sini tapır. Əvvəl ad (və ləqəb) ilə axtarılır,
    /// çünki Explore hələ mock id-lər işlədir; tapılmasa id-yə baxılır.
    static func apiID(for league: League) -> Int? {
        let key = ClubKey.make(league.name)
        if let match = entries.first(where: { entry in
            ([entry.name] + entry.aliases).contains { ClubKey.make($0) == key }
        }) {
            return match.id
        }
        return entries.first { $0.id == league.id }?.id
    }
}
