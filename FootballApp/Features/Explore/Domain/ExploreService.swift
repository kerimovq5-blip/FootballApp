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
