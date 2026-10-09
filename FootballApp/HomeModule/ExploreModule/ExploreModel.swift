//
//  ExploreModel.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

enum ExploreTab: Int, CaseIterable {
    case leagues
    case uefaClubs
    case fifaNations
    case uefaCountries

    var title: String {
        switch self {
        case .leagues: return "Leagues"
        case .uefaClubs: return "UEFA Clubs"
        case .fifaNations: return "FIFA Nations"
        case .uefaCountries: return "UEFA Countries"
        }
    }

    /// Sıralama cədvəlinin sütun başlığı; liqalar siyahısında cədvəl başlığı yoxdur.
    var columnTitle: String? {
        switch self {
        case .leagues: return nil
        case .uefaClubs: return "Club"
        case .fifaNations: return "Nation"
        case .uefaCountries: return "Country"
        }
    }
}

/// Üç sıralama cədvəli (UEFA klublar, FIFA ölkələr, UEFA ölkə xalları) eyni sətir modelindən istifadə edir.
struct RankingEntry {
    let rank: Int
    let name: String
    /// Klubda ölkə, FIFA-da konfederasiya.
    let subtitle: String?
    let flag: String
    let points: String
    /// Sıra dəyişikliyi (müsbət = yüksəlib). Olmayan cədvəllərdə nil.
    let change: Int?
}

struct ExploreContent {
    let leagues: [League]
    let uefaClubs: [RankingEntry]
    let fifaNations: [RankingEntry]
    let uefaCountries: [RankingEntry]
}
