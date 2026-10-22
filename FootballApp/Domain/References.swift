//
//  References.swift
//  FootballApp
//
//  Bir neçə feature-un bir-birinə ötürdüyü istinadlar (klub, oyunçu) və ümumi tiplər.
//

import Foundation

/// Klubu tanıtmaq üçün yüngül istinad. `id` məlumdursa klub birbaşa açılır, yoxdursa adla axtarılır.
struct ClubReference {
    let name: String
    /// Mənbə bilirsə (məs. axtarış nəticəsi) ötürülür, yoxsa liqadan götürülür.
    var country: String?
    var flag: String?
    /// API komanda id-si. Məlumdursa adla axtarış sorğusu qənaət olunur.
    var id: Int?
}

/// Oyunçunu tanıtmaq üçün yüngül istinad. `id` məlumdursa oyunçu birbaşa açılır,
/// yoxdursa (məs. köhnə hadisə datası) adla axtarılır.
struct PlayerReference {
    let name: String
    var clubName: String?
    var number: Int?
    /// API-Football oyunçu id-si.
    var id: Int?
}

enum ClubKey {
    /// Hərf böyüklüyü və işarələr (é, ş, ç...) nəzərə alınmadan müqayisə üçün açar.
    static func make(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .filter { $0.isLetter }
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
