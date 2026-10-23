//
//  ExploreTab.swift
//  FootballApp
//
//  Explore ekranının tab-ları.
//

import Foundation

enum ExploreTab: Int, CaseIterable {
    case leagues
    case topScorers
    case topAssists

    var title: String {
        switch self {
        case .leagues: return "Leagues"
        case .topScorers: return "Top scorers"
        case .topAssists: return "Top assists"
        }
    }

    /// Reytinq tab-larında hansı siyahının göstərildiyi; Leagues tab-ında nil.
    var topPlayersKind: TopPlayersKind? {
        switch self {
        case .leagues: return nil
        case .topScorers: return .goals
        case .topAssists: return .assists
        }
    }
}
