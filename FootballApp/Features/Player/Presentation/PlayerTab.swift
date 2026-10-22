//
//  PlayerTab.swift
//  FootballApp
//
//  Oyunçu səhifəsinin tab-ları.
//

import Foundation

enum PlayerTab: CaseIterable {
    case overview, statistics

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .statistics: return "Statistics"
        }
    }
}
