//
//  Standing.swift
//  FootballApp
//
//  Created by Servan on 01.10.26.
//

import UIKit

enum StandingZone {
    case championsLeague
    case relegation
    case none

    var backgroundColor: UIColor {
        switch self {
        case .championsLeague: return UIColor(red: 0.09, green: 0.17, blue: 0.38, alpha: 1)
        case .relegation: return UIColor(red: 0.36, green: 0.11, blue: 0.08, alpha: 1)
        case .none: return .clear
        }
    }
}

struct Standing {
    let position: Int
    let teamName: String
    let crestImageName: String?
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let zone: StandingZone
    
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
