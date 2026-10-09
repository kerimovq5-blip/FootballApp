//
//  MockData.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

/// API gələnə qədər müvəqqəti data. Home və detal service-i eyni mənbədən oxuyur.
enum MockData {
    static let leagues: [League] = [
        League(id: 1, name: "La Liga", country: "Spain", flag: "🇪🇸", matches: [
            Match(id: 1, home: "Barcelona", away: "Real Madrid", homeScore: 1, awayScore: 2, status: .live(minute: "63'")),
            Match(id: 2, home: "Sevilla", away: "Valencia", homeScore: nil, awayScore: nil, status: .scheduled(kickoff: "22:00"))
        ]),
        League(id: 2, name: "Premier League", country: "England", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", matches: [
            Match(id: 3, home: "Aston Villa", away: "Liverpool", homeScore: 2, awayScore: 3, status: .finished)
        ]),
        League(id: 3, name: "Trendyol Süper Lig", country: "Turkey", flag: "🇹🇷", matches: [
            Match(id: 4, home: "Besiktas", away: "Fenerbahce", homeScore: 3, awayScore: 1, status: .live(minute: "21'")),
            Match(id: 5, home: "Trabzonspor", away: "Galatasaray", homeScore: 0, awayScore: 1, status: .live(minute: "21'"))
        ]),
        League(id: 4, name: "UEFA Champions League", country: "Europe", flag: "🇪🇺", matches: [
            Match(id: 6, home: "Arsenal", away: "Aston Villa", homeScore: 2, awayScore: 0, status: .live(minute: "90+5'"))
        ])
    ]
}
