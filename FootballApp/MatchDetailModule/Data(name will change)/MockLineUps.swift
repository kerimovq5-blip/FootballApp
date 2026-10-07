//
//  MockLineUps.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import Foundation

/// API gələnə qədər test heyətləri. Real API-də `isConfirmed` rəsmi heyət elan olunub-olunmadığını göstərəcək.
enum MockLineups {

    static func make(for match: Match) -> MatchLineups {
        // Oyun başlayıbsa heyət rəsmidir; başlamayıbsa təxmini heyət göstərilir.
        let confirmed = match.status.hasStarted
        return MatchLineups(
            home: lineup(for: match.home, fallbackFormation: "4-3-3"),
            away: lineup(for: match.away, fallbackFormation: "4-4-2"),
            isConfirmed: confirmed
        )
    }

    // MARK: - Private

    private static func lineup(for team: String, fallbackFormation: String) -> TeamLineup {
        switch team {
        case "Arsenal": return arsenal
        case "Aston Villa": return astonVilla
        default: return placeholder(team: team, formation: fallbackFormation)
        }
    }

    /// Dizayndakı Arsenal heyəti (4-2-3-1).
    private static let arsenal = TeamLineup(
        teamName: "Arsenal",
        formation: "4-2-3-1",
        players: [
            LineupPlayer(number: 1, name: "Leno"),
            LineupPlayer(number: 3, name: "Tierney"),
            LineupPlayer(number: 22, name: "Pablo Mari"),
            LineupPlayer(number: 16, name: "Holding"),
            LineupPlayer(number: 2, name: "Bellerin"),
            LineupPlayer(number: 34, name: "Xhaka"),
            LineupPlayer(number: 8, name: "Dani Ceballos", yellowCards: 1),
            LineupPlayer(number: 14, name: "Aubameyang", goals: 1),
            LineupPlayer(number: 32, name: "Smith Rowe", isCaptain: true),
            LineupPlayer(number: 7, name: "Saka"),
            LineupPlayer(number: 9, name: "Lacazette")
        ]
    )

    private static let astonVilla = TeamLineup(
        teamName: "Aston Villa",
        formation: "4-2-3-1",
        players: [
            LineupPlayer(number: 1, name: "Martinez"),
            LineupPlayer(number: 18, name: "Targett"),
            LineupPlayer(number: 5, name: "Mings", isCaptain: true),
            LineupPlayer(number: 4, name: "Konsa"),
            LineupPlayer(number: 2, name: "Cash"),
            LineupPlayer(number: 6, name: "Luiz"),
            LineupPlayer(number: 7, name: "McGinn"),
            LineupPlayer(number: 22, name: "Traore"),
            LineupPlayer(number: 10, name: "Grealish"),
            LineupPlayer(number: 41, name: "Ramsey"),
            LineupPlayer(number: 11, name: "Watkins")
        ]
    )

    /// Real oyunçu datası olmayan komandalar üçün ümumi heyət.
    private static func placeholder(team: String, formation: String) -> TeamLineup {
        TeamLineup(
            teamName: team,
            formation: formation,
            players: (1...11).map { LineupPlayer(number: $0, name: "Player \($0)") }
        )
    }
}
