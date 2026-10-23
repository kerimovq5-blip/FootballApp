//
//  ExploreModel.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

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
