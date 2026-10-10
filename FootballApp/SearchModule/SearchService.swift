//
//  SearchContent.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


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
}

protocol SearchProviding {
    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void)
}

/// Real API gələnə qədər test datası: mövcud Explore və Home mock-larını birləşdirir.
struct MockSearchService: SearchProviding {

    private let homeService: HomeProviding
    private let exploreService: ExploreProviding

    init(homeService: HomeProviding = MockHomeService(),
         exploreService: ExploreProviding = MockExploreService()) {
        self.homeService = homeService
        self.exploreService = exploreService
    }

    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void) {
        exploreService.fetchExplore { exploreResult in
            homeService.fetchHome { homeResult in
                switch (exploreResult, homeResult) {
                case (.success(let explore), .success(let home)):
                    completion(.success(SearchContent(leagues: explore.leagues,
                                                      matchLeagues: home.leagues)))
                case (.failure(let error), _), (_, .failure(let error)):
                    completion(.failure(error))
                }
            }
        }
    }
}