//
//  ClubTab.swift
//  FootballApp
//
//  Klub səhifəsinin tab-ları.
//

import Foundation

enum ClubTab: CaseIterable {
    case overview, matches, standing, squad

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .matches: return "Matches"
        case .standing: return "Standing"
        case .squad: return "Squad"
        }
    }
}
