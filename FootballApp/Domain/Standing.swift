//
//  Standing.swift
//  FootballApp
//
//  Created by Servan on 01.10.26.
//

import Foundation

/// Cədvəldə komandanın zonası (rəngini Presentation qatı verir: `StandingZone+Color`).
enum StandingZone {
    case championsLeague
    case relegation
    case none
}

struct Standing {
    let position: Int
    let teamName: String
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let zone: StandingZone
    /// API-dən gələn loqo ünvanı.
    var crestURL: String?
    /// API-dən gələn komanda id-si (klub səhifəsini birbaşa açmaq üçün).
    var teamID: Int?
    var goalDifference: Int { goalsFor - goalsAgainst}
    var points: Int { wins * 3 + draws * 1 }
    
}

enum StandingFilter: CaseIterable {
    case all, home, away

    var title: String {
        switch self {
        case .all: return "All"
        case .home: return "Home"
        case .away: return "Away"
        }
    }
}
