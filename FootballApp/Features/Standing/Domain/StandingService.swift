//
//  StandingService.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
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
        case .leagueNotFound: return "No table is available for this league."
        }
    }
}
