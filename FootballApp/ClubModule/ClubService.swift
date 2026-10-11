//
//  ClubProviding.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubService.swift
//  FootballApp
//

import Foundation

protocol ClubProviding {
    func fetchClub(_ club: ClubReference,
                   completion: @escaping (Result<ClubDetailContent, Error>) -> Void)
}

/// Real API gələnə qədər test datası: Standing və Home mock-larını birləşdirir.
struct MockClubService: ClubProviding {

    private let standingService: StandingProviding
    private let homeService: HomeProviding

    init(standingService: StandingProviding = MockStandingService(),
         homeService: HomeProviding = MockHomeService()) {
        self.standingService = standingService
        self.homeService = homeService
    }

    func fetchClub(_ club: ClubReference,
                   completion: @escaping (Result<ClubDetailContent, Error>) -> Void) {
        let key = ClubKey.make(club.name)
        collectTables(leagues: standingService.leagues[...], key: key, collected: []) { tables in
            homeService.fetchHome { homeResult in
                let homeLeagues = (try? homeResult.get().leagues) ?? []
                completion(.success(
                    MockClubService.makeContent(club: club, key: key, tables: tables, homeLeagues: homeLeagues)
                ))
            }
        }
    }

    // MARK: - Cədvəllər

    /// Klubun olduğu bütün cədvəlləri bir-bir yığır (liqaların sırası saxlanılır).
    private func collectTables(leagues: ArraySlice<League>,
                               key: String,
                               collected: [ClubTable],
                               completion: @escaping ([ClubTable]) -> Void) {
        guard let league = leagues.first else {
            completion(collected)
            return
        }
        standingService.fetchStandings(for: league, filter: .all) { result in
            var next = collected
            if case .success(let standings) = result,
               standings.contains(where: { ClubKey.make($0.teamName) == key }) {
                next.append(ClubTable(league: league, standings: standings))
            }
            self.collectTables(leagues: leagues.dropFirst(), key: key, collected: next, completion: completion)
        }
    }

    // MARK: - Məzmun

    private static func makeContent(club: ClubReference,
                                    key: String,
                                    tables: [ClubTable],
                                    homeLeagues: [League]) -> ClubDetailContent {
        let domestic = tables.first { $0.league.country != "Europe" }
        let displayName = tables.lazy
            .compactMap { table in table.standings.first { ClubKey.make($0.teamName) == key }?.teamName }
            .first ?? club.name
        let fact = facts[key]

        let profile = ClubProfile(
            name: displayName,
            country: club.country ?? domestic?.league.country,
            flag: club.flag ?? domestic?.league.flag,
            founded: fact?.founded,
            stadium: fact?.stadium,
            competitions: tables.map { $0.league.name }
        )

        var upcoming: [ClubMatch] = []
        var results: [ClubMatch] = []

        // Home datasındakı real oyunlar (oyun detalı açıla bilir).
        for league in homeLeagues {
            for match in league.matches
            where ClubKey.make(match.home) == key || ClubKey.make(match.away) == key {
                let item = ClubMatch(matchID: match.id, competition: league.name, dateText: "Today",
                                     home: match.home, away: match.away,
                                     homeScore: match.homeScore, awayScore: match.awayScore,
                                     statusText: match.status.displayText, isLive: match.status.isLive)
                if case .finished = match.status {
                    results.append(item)
                } else {
                    upcoming.append(item)
                }
            }
        }

        if let domestic {
            let generated = generatedMatches(clubKey: key, clubName: displayName,
                                             league: domestic.league, standings: domestic.standings)
            upcoming += generated.upcoming
            results += generated.results
        }

        let form = results.prefix(5).compactMap { $0.result(for: key) }.reversed()
        return ClubDetailContent(
            profile: profile,
            form: Array(form),
            upcoming: upcoming,
            results: results,
            tables: tables,
            squad: MockSquad.make(clubKey: key,
                                  homeCountry: profile.country,
                                  homeFlag: profile.flag)
        )
    }

    /// Klub adından hesablanan sabit test oyunları (hər açılışda eyni görünür).
    private static func generatedMatches(clubKey: String,
                                         clubName: String,
                                         league: League,
                                         standings: [Standing]) -> (upcoming: [ClubMatch], results: [ClubMatch]) {
        let opponents = standings.map(\.teamName).filter { ClubKey.make($0) != clubKey }
        guard !opponents.isEmpty else { return ([], []) }

        let seed = clubKey.unicodeScalars.reduce(5381) { ($0 &* 33 &+ Int($1.value)) % 1_000_003 }
        func opponent(_ i: Int) -> String { opponents[(seed + i * 7) % opponents.count] }
        func isHome(_ i: Int) -> Bool { (seed + i) % 2 == 0 }
        func score(_ i: Int, _ salt: Int) -> Int { (seed &+ i &* 7 &+ salt &* 13) % 4 }

        let resultDates = ["04 Oct", "27 Sep", "20 Sep", "13 Sep", "30 Aug"]
        let results = resultDates.enumerated().map { i, date -> ClubMatch in
            let home = isHome(i)
            let own = score(i, 1)
            let other = score(i, 2)
            return ClubMatch(matchID: nil, competition: league.name, dateText: date,
                             home: home ? clubName : opponent(i),
                             away: home ? opponent(i) : clubName,
                             homeScore: home ? own : other,
                             awayScore: home ? other : own,
                             statusText: "FT", isLive: false)
        }

        let fixtures = [("18 Oct", "20:45"), ("25 Oct", "18:30"), ("01 Nov", "21:00"), ("08 Nov", "16:00")]
        let upcoming = fixtures.enumerated().map { i, fixture -> ClubMatch in
            let home = isHome(i + 5)
            let opp = opponent(i + 5)
            return ClubMatch(matchID: nil, competition: league.name, dateText: fixture.0,
                             home: home ? clubName : opp,
                             away: home ? opp : clubName,
                             homeScore: nil, awayScore: nil,
                             statusText: fixture.1, isLive: false)
        }
        return (upcoming, results)
    }

    // MARK: - Klub məlumatı (test datası, doğruluğunu yoxla)

    private struct Fact {
        let founded: Int
        let stadium: String?
    }

    private static let facts: [String: Fact] = {
        let list: [(String, Int, String?)] = [
            ("Arsenal", 1886, "Emirates Stadium"),
            ("Manchester City", 1880, "Etihad Stadium"),
            ("Liverpool", 1892, "Anfield"),
            ("Chelsea", 1905, "Stamford Bridge"),
            ("Tottenham Hotspur", 1882, "Tottenham Hotspur Stadium"),
            ("Newcastle", 1892, "St James' Park"),
            ("Aston Villa", 1874, "Villa Park"),
            ("Brighton", 1901, "Amex Stadium"),
            ("Everton", 1878, nil),
            ("Leicester", 1884, "King Power Stadium"),
            ("Barcelona", 1899, "Camp Nou"),
            ("Real Madrid", 1902, "Santiago Bernabéu"),
            ("Atlético Madrid", 1903, "Metropolitano"),
            ("Villarreal", 1923, "Estadio de la Cerámica"),
            ("Real Sociedad", 1909, "Reale Arena"),
            ("Athletic Club", 1898, "San Mamés"),
            ("Sevilla", 1890, "Ramón Sánchez-Pizjuán"),
            ("Valencia", 1919, "Mestalla"),
            ("Granada", 1931, "Nuevo Los Cármenes"),
            ("Cádiz", 1910, "Nuevo Mirandilla"),
            ("Inter", 1908, "San Siro"),
            ("AC Milan", 1899, "San Siro"),
            ("Juventus", 1897, "Allianz Stadium"),
            ("Napoli", 1926, "Stadio Diego Armando Maradona"),
            ("Atalanta", 1907, "Gewiss Stadium"),
            ("Roma", 1927, "Stadio Olimpico"),
            ("Lazio", 1900, "Stadio Olimpico"),
            ("Fiorentina", 1926, "Stadio Artemio Franchi"),
            ("Torino", 1906, "Stadio Olimpico Grande Torino"),
            ("Genoa", 1893, "Stadio Luigi Ferraris"),
            ("Galatasaray", 1905, "RAMS Park"),
            ("Fenerbahçe", 1907, "Şükrü Saracoğlu Stadium"),
            ("Beşiktaş", 1903, "Beşiktaş Park"),
            ("Trabzonspor", 1967, nil),
            ("Bayern München", 1900, "Allianz Arena"),
            ("Borussia Dortmund", 1909, "Signal Iduna Park"),
            ("Bayer Leverkusen", 1904, "BayArena"),
            ("Paris Saint-Germain", 1970, "Parc des Princes"),
            ("Benfica", 1904, "Estádio da Luz"),
            ("Porto", 1893, "Estádio do Dragão"),
            ("Sporting CP", 1906, "Estádio José Alvalade")
        ]
        return Dictionary(list.map { (ClubKey.make($0.0), Fact(founded: $0.1, stadium: $0.2)) },
                          uniquingKeysWith: { first, _ in first })
    }()
}
