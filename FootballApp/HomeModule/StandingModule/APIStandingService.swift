//
//  APIStandingService.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

//
//  APIStandingService.swift
//  FootballApp
//

import Foundation

struct APIStandingService: StandingProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    var leagues: [League] { APILeagueCatalog.leagues }

    func fetchStandings(for league: League,
                        filter: StandingFilter,
                        completion: @escaping (Result<[Standing], Error>) -> Void) {
        guard let apiID = APILeagueCatalog.apiID(for: league) else {
            completion(.failure(StandingError.leagueNotFound))
            return
        }

        client.standings(league: apiID, season: APIConfig.season) { result in
            switch result {
            case .success(let dtos):
                let standings = APIFootballMapper.standings(from: dtos, filter: filter)
                if standings.isEmpty {
                    completion(.failure(StandingError.leagueNotFound))
                } else {
                    completion(.success(standings))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
