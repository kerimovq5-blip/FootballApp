//
//  PlayerModels.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

import Foundation

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
