//
//  StandingService.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//

//
//  StandingService.swift
//  FootballApp
//

import Foundation

protocol StandingProviding {
    /// Tab-da göstərilən liqalar.
    var leagues: [League] { get }
    func fetchStandings(for league: League,
                        filter: StandingFilter,
                        completion: @escaping (Result<[Standing], Error>) -> Void)
}
enum StandingError: LocalizedError {
    case leagueNotFound

    var errorDescription: String? {
        switch self {
        case .leagueNotFound: return "Bu liqa üçün cədvəl tapılmadı."
        }
    }
}

/// Real API gələnə qədər test datası. Rəqəmlər uydurmadır, real nəticələr deyil.
struct MockStandingService: StandingProviding {

    let leagues: [League] = [
        League(id: 101, name: "Premier League", country: "England", flag: "🇬🇧", matches: []),
        League(id: 102, name: "La Liga", country: "Spain", flag: "🇪🇸", matches: []),
        League(id: 103, name: "Serie A", country: "Italy", flag: "🇮🇹", matches: []),
        League(id: 106, name: "Trendyol Süper Lig", country: "Turkey", flag: "🇹🇷", matches: [])
    ]
    func fetchStandings(for league: League,
                        filter: StandingFilter,
                        completion: @escaping (Result<[Standing], Error>) -> Void) {
        guard let rows = MockStandingService.rows[league.name] else {
                    completion(.failure(StandingError.leagueNotFound))
                    return
        }

        let source: [Row]
        switch filter {
        case .all: source = rows
        case .home: source = rows.map { $0.half(isHome: true) }
        case .away: source = rows.map { $0.half(isHome: false) }
        }
        completion(.success(MockStandingService.makeStandings(from: source)))
    }

    // MARK: - Helpers

    private struct Row {
        let name: String
        let w: Int, d: Int, l: Int, gf: Int, ga: Int

        var points: Int { w * 3 + d }
        var goalDifference: Int { gf - ga }

        /// Home/Away üçün test datası: ümumi rəqəmləri təxminən yarıya bölür.
        func half(isHome: Bool) -> Row {
            func part(_ value: Int) -> Int { isHome ? (value + 1) / 2 : value / 2 }
            return Row(name: name, w: part(w), d: part(d), l: part(l), gf: part(gf), ga: part(ga))
        }
    }

    private static func makeStandings(from rows: [Row]) -> [Standing] {
        let sorted = rows.sorted {
            if $0.points != $1.points { return $0.points > $1.points }
            if $0.goalDifference != $1.goalDifference { return $0.goalDifference > $1.goalDifference }
            return $0.gf > $1.gf
        }
        return sorted.enumerated().map { index, row in
            let position = index + 1
            return Standing(position: position,
                            teamName: row.name,
                            crestImageName: nil,
                            played: row.w + row.d + row.l,
                            wins: row.w,
                            draws: row.d,
                            losses: row.l,
                            goalsFor: row.gf,
                            goalsAgainst: row.ga,
                            zone: zone(position: position, total: sorted.count))
        }
    }

    private static func zone(position: Int, total: Int) -> StandingZone {
        if position <= 4 { return .championsLeague }
        if position > total - 3 { return .relegation }
        return .none
    }

    private static func row(_ name: String, _ w: Int, _ d: Int, _ l: Int,
                            _ gf: Int, _ ga: Int) -> Row {
        Row(name: name, w: w, d: d, l: l, gf: gf, ga: ga)
    }

    // MARK: - Data (liqa id -> komandalar)

    private static let rows: [String: [Row]] = [
        "Premier League": [
            row("Arsenal", 8, 2, 1, 24, 8),
            row("Man City", 7, 3, 1, 26, 10),
            row("Liverpool", 7, 2, 2, 22, 11),
            row("Chelsea", 6, 3, 2, 20, 12),
            row("Tottenham", 5, 3, 3, 19, 15),
            row("Newcastle", 5, 2, 4, 17, 14),
            row("Aston Villa", 4, 3, 4, 15, 16),
            row("Brighton", 3, 3, 5, 13, 17),
            row("Everton", 2, 3, 6, 9, 18),
            row("Leicester", 1, 2, 8, 8, 24)
        ],
        "La Liga": [
            row("Barcelona", 8, 2, 1, 28, 9),
            row("Real Madrid", 7, 3, 1, 25, 10),
            row("Atlético Madrid", 7, 2, 2, 21, 9),
            row("Villarreal", 6, 2, 3, 20, 13),
            row("Real Sociedad", 5, 3, 3, 16, 12),
            row("Athletic Club", 5, 2, 4, 15, 13),
            row("Sevilla", 4, 3, 4, 14, 16),
            row("Valencia", 3, 3, 5, 12, 17),
            row("Granada", 2, 2, 7, 10, 22),
            row("Cádiz", 1, 3, 7, 7, 21)
        ],
        "Serie A": [
            row("Inter", 8, 2, 1, 25, 9),
            row("Napoli", 7, 3, 1, 21, 8),
            row("Juventus", 7, 2, 2, 19, 9),
            row("AC Milan", 6, 3, 2, 20, 12),
            row("Atalanta", 6, 1, 4, 22, 15),
            row("Roma", 5, 3, 3, 16, 12),
            row("Lazio", 4, 3, 4, 15, 15),
            row("Fiorentina", 3, 4, 4, 13, 15),
            row("Torino", 2, 3, 6, 9, 17),
            row("Genoa", 1, 3, 7, 8, 22)
        ],
        "Trendyol Süper Lig": [
                    row("Besiktas", 8, 2, 1, 26, 9),
                    row("Fenerbahçe", 7, 3, 1, 24, 10),
                    row("Galatasaray", 6, 3, 2, 20, 12),
                    row("Trabzonspor", 6, 2, 3, 19, 13),
                    row("Başakşehir", 5, 3, 3, 16, 12),
                    row("Samsunspor", 4, 4, 3, 14, 13),
                    row("Kasımpaşa", 4, 2, 5, 13, 16),
                    row("Konyaspor", 3, 3, 5, 11, 15),
                    row("Rizespor", 2, 3, 6, 9, 18),
                    row("Kayserispor", 1, 3, 7, 8, 21)
                ]
    ]
}
