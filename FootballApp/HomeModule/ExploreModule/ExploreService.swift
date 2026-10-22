//
//  ExploreService.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

protocol ExploreProviding {
    /// Explore-da göstərilən liqalar (sorğusuz, yerli siyahı).
    var leagues: [League] { get }
    /// Liqanın ən çox qol vuran və ya ən çox məhsuldar ötürmə verən oyunçuları.
    func topPlayers(_ kind: TopPlayersKind, in league: League) async throws -> [RankingEntry]
}

struct APIExploreService: ExploreProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    var leagues: [League] {
        APILeagueCatalog.leagues
    }

    func topPlayers(_ kind: TopPlayersKind, in league: League) async throws -> [RankingEntry] {
        guard let leagueID = APILeagueCatalog.apiID(for: league) else { throw APIError.notFound }
        let items: [PlayerStatsDTO]
        switch kind {
        case .goals: items = try await client.topScorers(league: leagueID, season: APIConfig.season)
        case .assists: items = try await client.topAssists(league: leagueID, season: APIConfig.season)
        }
        return APIFootballMapper.topPlayers(from: items, kind: kind)
    }
}
