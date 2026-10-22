//
//  PlayerModels.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

import Foundation

/// Oyunçunu tanıtmaq üçün yüngül istinad. `id` məlumdursa oyunçu birbaşa açılır,
/// yoxdursa (məs. köhnə hadisə datası) adla axtarılır.
struct PlayerReference {
    let name: String
    var clubName: String?
    var number: Int?
    /// API-Football oyunçu id-si.
    var id: Int?
}

enum PlayerTab: CaseIterable {
    case overview, statistics

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .statistics: return "Statistics"
        }
    }
}

struct PlayerProfile {
    let name: String
    let number: Int?
    let position: PlayerPosition?
    let age: Int?
    /// API-nin yazdığı kimi ("Brazil"); məlum deyilsə boş.
    let nationality: String
    /// Bayraq emojisi; tapılmasa boş.
    let flag: String
    /// "180 cm"
    let height: String?
    let photoURL: String?
    let club: ClubReference
}

struct PlayerStatRow {
    let label: String
    let value: String
}

struct PlayerStatSection {
    let title: String
    let rows: [PlayerStatRow]
}

struct PlayerDetailContent {
    let profile: PlayerProfile
    /// "2024/25" kimi.
    let season: String
    /// Overview-dakı 4 əsas göstərici.
    let summary: [PlayerStatRow]
    let statistics: [PlayerStatSection]
}
