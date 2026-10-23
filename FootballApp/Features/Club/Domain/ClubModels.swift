//
//  ClubModels.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

import Foundation

struct SquadPlayer {
    let number: Int
    let name: String
    let position: PlayerPosition
    let age: Int
    let nationality: String
    let flag: String
    /// API id-si (oyunçu səhifəsini açmaq üçün).
    var id: Int?
}

enum ClubResult {
    case win, draw, loss

    var title: String {
        switch self {
        case .win: return "W"
        case .draw: return "D"
        case .loss: return "L"
        }
    }
}

struct ClubMatch {
    /// Oyun detalı olan oyunlarda dolu olur; yoxdursa sətrə toxunmaq bir şey açmır.
    let matchID: Int?
    let competition: String
    let dateText: String
    let home: String
    let away: String
    let homeScore: Int?
    let awayScore: Int?
    /// Canlıda dəqiqə, gələcək oyunda start vaxtı, bitmişdə "FT".
    let statusText: String
    let isLive: Bool

    /// Klub baxımından nəticə (hesab yoxdursa nil).
    func result(for clubKey: String) -> ClubResult? {
        guard let homeScore, let awayScore else { return nil }
        let isHome = ClubKey.make(home) == clubKey
        let own = isHome ? homeScore : awayScore
        let other = isHome ? awayScore : homeScore
        if own > other { return .win }
        return own == other ? .draw : .loss
    }
}

struct ClubProfile {
    let name: String
    let country: String?
    let flag: String?
    let founded: Int?
    let stadium: String?
    let competitions: [String]
}

/// Klubun iştirak etdiyi bir turnirin cədvəli.
struct ClubTable {
    let league: League
    let standings: [Standing]
}

struct ClubDetailContent {
    let profile: ClubProfile
    /// Son oyunlar, köhnədən yeniyə (ən yenisi sağda).
    let form: [ClubResult]
    /// Canlı və gələcək oyunlar.
    let upcoming: [ClubMatch]
    /// Bitmiş oyunlar, ən yenisi birinci.
    let results: [ClubMatch]
    /// Domestik liqa birinci gəlir.
    let tables: [ClubTable]
    /// Heyət, mövqe və forma nömrəsi ilə.
    let squad: [SquadPlayer]
}
