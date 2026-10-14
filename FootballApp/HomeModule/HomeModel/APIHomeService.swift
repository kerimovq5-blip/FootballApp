//
//  APIHomeService.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  APIHomeService.swift
//  FootballApp
//

import Foundation

struct APIHomeService: HomeProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    func fetchHome(completion: @escaping (Result<HomeContent, Error>) -> Void) {
        client.fixtures(date: APIConfig.homeDate) { result in
            switch result {
            case .success(let fixtures):
                let leagues = APIFootballMapper.leagues(from: fixtures, allowedIDs: APIConfig.homeLeagueIDs)
                // API-də banner yoxdur, bannerlər hələlik mock-dur.
                completion(.success(HomeContent(banners: HomeMockData.banners, leagues: leagues)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}