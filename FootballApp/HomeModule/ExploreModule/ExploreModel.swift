//
//  ExploreModel.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
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

enum TopPlayersKind {
    case goals
    case assists

    /// Cədvəlin sağ sütununun başlığı.
    var valueTitle: String {
        switch self {
        case .goals: return "Goals"
        case .assists: return "Assists"
        }
    }
}

/// Reytinq sətri: sıra, oyunçu, klubu və göstərici (qol və ya məhsuldar ötürmə).
struct RankingEntry {
    let rank: Int
    let name: String
    /// Oyunçunun klubu.
    let subtitle: String?
    let imageURL: String?
    let value: String
    /// Sətrə toxunanda açılan oyunçu.
    let player: PlayerReference?
}
