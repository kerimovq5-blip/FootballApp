//
//  APIFootballMapper+Standing.swift
//  FootballApp
//
//  Liqa cədvəli (All / Home / Away).
//

import Foundation

extension APIFootballMapper {

    // MARK: - Standing

    static func standings(from dtos: [StandingsDTO], filter: StandingFilter) -> [Standing] {
        guard let info = dtos.first?.league else { return [] }
        let rows = info.standings.flatMap { $0 }

        switch filter {
        case .all:
            return rows.map {
                mapStanding($0, record: $0.all, position: $0.rank, zone: mapZone($0.description))
            }
        case .home, .away:
            // Home/Away cədvəli həmin oyunların nəticələrinə görə yenidən sıralanır, zona rəngi olmur.
            let items = rows.map { row in
                (row: row, record: (filter == .home ? row.home : row.away) ?? row.all)
            }
            let sorted = items.sorted { lhs, rhs in
                let leftPoints = lhs.record.win * 3 + lhs.record.draw
                let rightPoints = rhs.record.win * 3 + rhs.record.draw
                if leftPoints != rightPoints { return leftPoints > rightPoints }

                let leftDiff = lhs.record.goals.scored - lhs.record.goals.conceded
                let rightDiff = rhs.record.goals.scored - rhs.record.goals.conceded
                if leftDiff != rightDiff { return leftDiff > rightDiff }

                return lhs.record.goals.scored > rhs.record.goals.scored
            }
            return sorted.enumerated().map { index, item in
                mapStanding(item.row, record: item.record, position: index + 1, zone: .none)
            }
        }
    }

    private static func mapStanding(_ row: StandingsDTO.Row,
                                    record: StandingsDTO.Record,
                                    position: Int,
                                    zone: StandingZone) -> Standing {
        Standing(position: position,
                 teamName: row.team.name,
                 played: record.played,
                 wins: record.win,
                 draws: record.draw,
                 losses: record.lose,
                 goalsFor: record.goals.scored,
                 goalsAgainst: record.goals.conceded,
                 zone: zone,
                 crestURL: row.team.logo,
                 teamID: row.team.id)
    }

    /// API-nin izahından ("Promotion - Champions League...") zona rəngi.
    private static func mapZone(_ description: String?) -> StandingZone {
        let text = (description ?? "").lowercased()
        if text.contains("relegation") || text.contains("elimination") { return .relegation }
        if text.contains("champions league") { return .championsLeague }
        return .none
    }
}
