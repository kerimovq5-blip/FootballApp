//
//  SearchService.swift
//  FootballApp
//

import Foundation

struct SearchContent {
    /// Axtarışda liqa kimi tapılan liqalar.
    let leagues: [League]
    /// Oyunları olan liqalar (Home ilə eyni mənbə).
    let matchLeagues: [League]
    /// Axtarışda komanda kimi tapılan klublar.
    var clubs: [ClubReference] = []
}

protocol SearchProviding {
    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void)
}

/// Real API gələnə qədər test datası: Explore, Home və Standing mock-larını birləşdirir.
struct MockSearchService: SearchProviding {

    private let homeService: HomeProviding
    private let exploreService: ExploreProviding
    private let standingService: StandingProviding

    init(homeService: HomeProviding = MockHomeService(),
         exploreService: ExploreProviding = MockExploreService(),
         standingService: StandingProviding = MockStandingService()) {
        self.homeService = homeService
        self.exploreService = exploreService
        self.standingService = standingService
    }

    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void) {
        exploreService.fetchExplore { exploreResult in
            self.homeService.fetchHome { homeResult in
                self.collectStandingClubs(leagues: self.standingService.leagues[...], collected: []) { standingClubs in
                    switch (exploreResult, homeResult) {
                    case (.success(let explore), .success(let home)):
                        let clubs = MockSearchService.mergeClubs(explore: explore,
                                                                 home: home,
                                                                 standingClubs: standingClubs)
                        completion(.success(SearchContent(leagues: explore.leagues,
                                                          matchLeagues: home.leagues,
                                                          clubs: clubs)))
                    case (.failure(let error), _), (_, .failure(let error)):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    // MARK: - Klublar

    /// Liqa cədvəllərindəki komandalar (Avropa turnirləri keçilir, klublar domestik liqada artıq var).
    private func collectStandingClubs(leagues: ArraySlice<League>,
                                      collected: [ClubReference],
                                      completion: @escaping ([ClubReference]) -> Void) {
        guard let league = leagues.first else {
            completion(collected)
            return
        }
        guard league.country != "Europe" else {
            collectStandingClubs(leagues: leagues.dropFirst(), collected: collected, completion: completion)
            return
        }
        standingService.fetchStandings(for: league, filter: .all) { result in
            var next = collected
            if case .success(let standings) = result {
                next += standings.map {
                    ClubReference(name: $0.teamName, country: league.country, flag: league.flag)
                }
            }
            self.collectStandingClubs(leagues: leagues.dropFirst(), collected: next, completion: completion)
        }
    }

    /// Eyni klub bir dəfə qalır (ad işarələrdən asılı olmadan müqayisə olunur), əlifba sırası ilə.
    private static func mergeClubs(explore: ExploreContent,
                                   home: HomeContent,
                                   standingClubs: [ClubReference]) -> [ClubReference] {
        var all = explore.uefaClubs.map {
            ClubReference(name: $0.name, country: $0.subtitle, flag: $0.flag)
        }
        all += standingClubs
        for league in home.leagues {
            for match in league.matches {
                all.append(ClubReference(name: match.home))
                all.append(ClubReference(name: match.away))
            }
        }

        var seen = Set<String>()
        return all
            .filter { seen.insert(ClubKey.make($0.name)).inserted }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
