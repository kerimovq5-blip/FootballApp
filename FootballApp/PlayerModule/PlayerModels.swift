//
//  PlayerReference.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

//
//  PlayerModels.swift
//  FootballApp
//

import UIKit

/// Oyunçunu tanıtmaq üçün yüngül istinad. Mock datada ad və klub ilə tanınır; API gələndə id əlavə olunacaq.
struct PlayerReference {
    let name: String
    var clubName: String?
    var number: Int?
}

enum PlayerTab: CaseIterable {
    case overview, matches, statistics

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .matches: return "Matches"
        case .statistics: return "Statistics"
        }
    }
}

struct PlayerProfile {
    let name: String
    let number: Int
    let position: PlayerPosition
    let age: Int
    let nationality: String
    let flag: String
    let heightCm: Int
    let preferredFoot: String
    let club: ClubReference
}

struct PlayerMatch {
    /// Oyun detalı olan oyunlarda dolu olur.
    let matchID: Int?
    let competition: String
    let dateText: String
    let home: String
    let away: String
    let homeScore: Int?
    let awayScore: Int?
    let minutes: Int
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let rating: Double?

    var didPlay: Bool { minutes > 0 }
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
    /// "2026/27" kimi.
    let season: String
    /// Overview-dakı 4 əsas göstərici.
    let summary: [PlayerStatRow]
    /// Ən yenisi birinci.
    let matches: [PlayerMatch]
    let statistics: [PlayerStatSection]
}

enum PlayerRating {
    static func text(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    static func color(_ value: Double) -> UIColor {
        if value >= 7.0 { return .systemGreen }
        if value >= 6.0 { return .systemOrange }
        return .systemRed
    }
}
