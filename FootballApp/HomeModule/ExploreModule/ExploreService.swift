//
//  ExploreService.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

protocol ExploreProviding {
    func fetchExplore(completion: @escaping (Result<ExploreContent, Error>) -> Void)
}

/// Real API gələnə qədər test datası. Xallar təxminidir, real rəqəmlər deyil.
struct MockExploreService: ExploreProviding {

    func fetchExplore(completion: @escaping (Result<ExploreContent, Error>) -> Void) {
        completion(.success(ExploreContent(
            leagues: MockExploreService.leagues,
            uefaClubs: MockExploreService.uefaClubs,
            fifaNations: MockExploreService.fifaNations,
            uefaCountries: MockExploreService.uefaCountries
        )))
    }

    // MARK: - Leagues

    private static let leagues: [League] = [
        League(id: 101, name: "Premier League", country: "England", flag: "🇬🇧", matches: []),
        League(id: 102, name: "La Liga", country: "Spain", flag: "🇪🇸", matches: []),
        League(id: 103, name: "Serie A", country: "Italy", flag: "🇮🇹", matches: []),
        League(id: 104, name: "Bundesliga", country: "Germany", flag: "🇩🇪", matches: []),
        League(id: 105, name: "Ligue 1", country: "France", flag: "🇫🇷", matches: []),
        League(id: 106, name: "Trendyol Süper Lig", country: "Turkey", flag: "🇹🇷", matches: []),
        League(id: 107, name: "Azerbaijan Premier League", country: "Azerbaijan", flag: "🇦🇿", matches: []),
        League(id: 108, name: "UEFA Champions League", country: "Europe", flag: "🇪🇺", matches: []),
        League(id: 109, name: "UEFA Europa League", country: "Europe", flag: "🇪🇺", matches: [])
    ]

    // MARK: - UEFA club ranking

    private static let uefaClubs: [RankingEntry] = [
        club(1, "Manchester City", "England", "🇬🇧", "148.000"),
        club(2, "Real Madrid", "Spain", "🇪🇸", "143.750"),
        club(3, "Bayern München", "Germany", "🇩🇪", "140.250"),
        club(4, "Liverpool", "England", "🇬🇧", "132.250"),
        club(5, "Inter", "Italy", "🇮🇹", "130.500"),
        club(6, "Paris Saint-Germain", "France", "🇫🇷", "126.000"),
        club(7, "Barcelona", "Spain", "🇪🇸", "124.250"),
        club(8, "Arsenal", "England", "🇬🇧", "121.000"),
        club(9, "Atlético Madrid", "Spain", "🇪🇸", "118.500"),
        club(10, "Borussia Dortmund", "Germany", "🇩🇪", "115.750"),
        club(11, "Bayer Leverkusen", "Germany", "🇩🇪", "112.000"),
        club(12, "Juventus", "Italy", "🇮🇹", "109.500"),
        club(13, "AC Milan", "Italy", "🇮🇹", "106.250"),
        club(14, "Atalanta", "Italy", "🇮🇹", "103.000"),
        club(15, "Benfica", "Portugal", "🇵🇹", "99.750"),
        club(16, "Porto", "Portugal", "🇵🇹", "96.500"),
        club(17, "Sporting CP", "Portugal", "🇵🇹", "93.250"),
        club(18, "Roma", "Italy", "🇮🇹", "90.000"),
        club(19, "Napoli", "Italy", "🇮🇹", "87.750"),
        club(20, "Tottenham Hotspur", "England", "🇬🇧", "85.500")
    ]

    private static func club(_ rank: Int, _ name: String, _ country: String,
                             _ flag: String, _ points: String) -> RankingEntry {
        RankingEntry(rank: rank, name: name, subtitle: country, flag: flag, points: points, change: nil)
    }

    // MARK: - FIFA nations ranking

    private static let fifaNations: [RankingEntry] = [
        nation(1, "Spain", "UEFA", "🇪🇸", 1877, 1),
        nation(2, "Argentina", "CONMEBOL", "🇦🇷", 1873, -1),
        nation(3, "France", "UEFA", "🇫🇷", 1870, 0),
        nation(4, "England", "UEFA", "🇬🇧", 1834, 1),
        nation(5, "Brazil", "CONMEBOL", "🇧🇷", 1760, -1),
        nation(6, "Portugal", "UEFA", "🇵🇹", 1756, 0),
        nation(7, "Netherlands", "UEFA", "🇳🇱", 1748, 2),
        nation(8, "Morocco", "CAF", "🇲🇦", 1736, 0),
        nation(9, "Belgium", "UEFA", "🇧🇪", 1731, -2),
        nation(10, "Germany", "UEFA", "🇩🇪", 1724, 1),
        nation(11, "Croatia", "UEFA", "🇭🇷", 1717, 0),
        nation(12, "Colombia", "CONMEBOL", "🇨🇴", 1701, 1),
        nation(13, "Italy", "UEFA", "🇮🇹", 1695, -1),
        nation(14, "Uruguay", "CONMEBOL", "🇺🇾", 1672, 0),
        nation(15, "Japan", "AFC", "🇯🇵", 1660, 3),
        nation(16, "United States", "CONCACAF", "🇺🇸", 1649, -1),
        nation(17, "Mexico", "CONCACAF", "🇲🇽", 1641, 0),
        nation(18, "Senegal", "CAF", "🇸🇳", 1632, 1),
        nation(19, "Switzerland", "UEFA", "🇨🇭", 1625, -2),
        nation(20, "Denmark", "UEFA", "🇩🇰", 1611, 0)
    ]

    private static func nation(_ rank: Int, _ name: String, _ confederation: String,
                               _ flag: String, _ points: Int, _ change: Int) -> RankingEntry {
        RankingEntry(rank: rank, name: name, subtitle: confederation, flag: flag,
                     points: "\(points)", change: change)
    }

    // MARK: - UEFA country (association) ranking

    private static let uefaCountries: [RankingEntry] = [
        country(1, "England", "🇬🇧", "95.482"),
        country(2, "Italy", "🇮🇹", "90.248"),
        country(3, "Spain", "🇪🇸", "85.116"),
        country(4, "Germany", "🇩🇪", "82.482"),
        country(5, "France", "🇫🇷", "74.231"),
        country(6, "Netherlands", "🇳🇱", "66.175"),
        country(7, "Portugal", "🇵🇹", "63.916"),
        country(8, "Belgium", "🇧🇪", "57.100"),
        country(9, "Turkey", "🇹🇷", "49.500"),
        country(10, "Czechia", "🇨🇿", "47.250"),
        country(11, "Austria", "🇦🇹", "46.200"),
        country(12, "Poland", "🇵🇱", "45.675"),
        country(13, "Greece", "🇬🇷", "44.600"),
        country(14, "Norway", "🇳🇴", "43.500"),
        country(15, "Switzerland", "🇨🇭", "42.250"),
        country(16, "Denmark", "🇩🇰", "40.900"),
        country(17, "Cyprus", "🇨🇾", "38.750"),
        country(18, "Israel", "🇮🇱", "36.500")
    ]

    private static func country(_ rank: Int, _ name: String, _ flag: String,
                                _ points: String) -> RankingEntry {
        RankingEntry(rank: rank, name: name, subtitle: nil, flag: flag, points: points, change: nil)
    }
}
