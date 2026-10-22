//
//  LineUp.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import Foundation

struct LineupPlayer {
    let number: Int
    let name: String
    var isCaptain = false
    var goals = 0
    var yellowCards = 0
    var isSentOff = false
    /// API id-si (oyunçu səhifəsini açmaq üçün).
    var id: Int?
}

struct TeamLineup {
    let teamName: String
    /// "4-2-3-1" kimi (qapıçı daxil deyil).
    let formation: String
    /// 11 oyunçu: əvvəl qapıçı, sonra xətlər üzrə (müdafiə → hücum), hər xətt soldan sağa.
    let players: [LineupPlayer]
}

struct MatchLineups {
    let home: TeamLineup
    let away: TeamLineup
    /// false olanda rəsmi heyət hələ elan olunmayıb, göstərilən təxmini (probable) heyətdir.
    let isConfirmed: Bool
}
