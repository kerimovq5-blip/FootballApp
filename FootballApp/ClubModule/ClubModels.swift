//
//  ClubReference.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

import UIKit

/// Klubu tanıtmaq üçün yüngül istinad. `id` məlumdursa klub birbaşa açılır, yoxdursa adla axtarılır.
struct ClubReference {
    let name: String
    /// Mənbə bilirsə (məs. axtarış nəticəsi) ötürülür, yoxsa liqadan götürülür.
    var country: String?
    var flag: String?
    /// API komanda id-si. Məlumdursa adla axtarış sorğusu qənaət olunur.
    var id: Int?
}
enum ClubKey {
    /// Hərf böyüklüyü və işarələr (é, ş, ç...) nəzərə alınmadan müqayisə üçün açar.
    static func make(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .filter { $0.isLetter }
    }
}

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
enum PlayerPosition: CaseIterable {
    case goalkeeper, defender, midfielder, forward

    /// Heyət siyahısındakı bölmə başlığı.
    var title: String {
        switch self {
        case .goalkeeper: return "Goalkeepers"
        case .defender: return "Defenders"
        case .midfielder: return "Midfielders"
        case .forward: return "Forwards"
        }
        
    }
    /// Tək oyunçunun mövqeyi: "Midfielder".
    var singularTitle: String {
        switch self {
        case .goalkeeper: return "Goalkeeper"
        case .defender: return "Defender"
        case .midfielder: return "Midfielder"
        case .forward: return "Forward"
        }
    }
}

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

    var color: UIColor {
        switch self {
        case .win: return .systemGreen
        case .draw: return UIColor.white.withAlphaComponent(0.35)
        case .loss: return .systemRed
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
