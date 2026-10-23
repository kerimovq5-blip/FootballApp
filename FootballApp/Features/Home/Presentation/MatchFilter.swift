//
//  MatchFilter.swift
//  FootballApp
//
//  Home-dakı "All / Live" filtri.
//

import Foundation

enum MatchFilter: CaseIterable {
    case all
    case live

    var title: String {
        switch self {
        case .all: return "All"
        case .live: return "Live"
        }
    }
}
