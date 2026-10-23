//
//  APIFootballMapper+MatchDetail.swift
//  FootballApp
//
//  Oyun detalı: hadisələr, heyətlər, statistika, H2H.
//

import Foundation

extension APIFootballMapper {

    // MARK: - Match detail

    static func matchDetail(fixture dto: FixtureDTO,
                            headToHead h2hFixtures: [FixtureDTO]) -> MatchDetailData {
        let current = mapMatch(dto)
        let started = current.status.hasStarted
        let homeID = dto.teams.home.id

        return MatchDetailData(
            competitionName: dto.league.name,
            homeName: dto.teams.home.name,
            awayName: dto.teams.away.name,
            homeCrestURL: dto.teams.home.logo,
            awayCrestURL: dto.teams.away.logo,
            // Başlamamış oyunda hesab əvəzinə start vaxtı göstərilir.
            score: started ? "\(dto.goals.home ?? 0) - \(dto.goals.away ?? 0)" : current.status.displayText,
            minuteOrStatus: started ? current.status.displayText : "Not started",
            hasStarted: started,
            stats: mapStats(dto.statistics ?? [], homeID: homeID),
            events: mapEvents(dto.events ?? [], homeID: homeID, halftime: dto.score?.halftime),
            lineups: mapLineups(dto),
            headToHead: mapHeadToHead(h2hFixtures, homeID: homeID)
        )
    }

    // MARK: - Hadisələr

    private static func mapEvents(_ dtos: [EventDTO],
                                  homeID: Int?,
                                  halftime: FixtureDTO.Goals?) -> [MatchEvent] {
        var halftimeScore: String?
        if let home = halftime?.home, let away = halftime?.away {
            halftimeScore = "\(home) - \(away)"
        }

        var result: [MatchEvent] = []
        var halftimeInserted = false

        for dto in dtos {
            guard let event = mapEvent(dto, homeID: homeID) else { continue }

            // "Half time" xətti birinci yarıdan sonrakı ilk hadisənin qarşısına qoyulur.
            if let halftimeScore, !halftimeInserted, (dto.time.elapsed ?? 0) > 45 {
                result.append(.halfTime(score: halftimeScore))
                halftimeInserted = true
            }
            result.append(event)
        }

        if let halftimeScore, !halftimeInserted {
            result.append(.halfTime(score: halftimeScore))
        }
        return result
    }

    private static func mapEvent(_ dto: EventDTO, homeID: Int?) -> MatchEvent? {
        let detail = (dto.detail ?? "").lowercased()
        let kind: MatchEvent.Kind

        switch dto.type.lowercased() {
        case "goal":
            if detail.contains("own") {
                kind = .ownGoal
            } else if detail.contains("missed") {
                return nil
            } else if detail.contains("penalty") {
                kind = .penaltyGoal
            } else {
                kind = .goal
            }
        case "card":
            kind = (detail.contains("red") || detail.contains("second")) ? .redCard : .yellowCard
        case "subst":
            kind = .substitution
        default:
            return nil
        }

        var side: MatchEvent.Side = dto.team.id == homeID ? .home : .away
        // Öz qapısına vuruşda qolu qazanan komanda rəqibdir.
        if kind == .ownGoal {
            side = side == .home ? .away : .home
        }

        var minute = ""
        if let elapsed = dto.time.elapsed {
            if let extra = dto.time.extra, extra > 0 {
                minute = "\(elapsed)+\(extra)'"
            } else {
                minute = "\(elapsed)'"
            }
        }

        switch kind {
        case .substitution:
            // API-də `player` çıxan, `assist` girən oyunçudur; bizdə əsas ad girən oyunçudur.
            return MatchEvent(minute: minute, kind: kind, side: side,
                              player: dto.assist?.name ?? "–",
                              detail: dto.player?.name.map { "Out: \($0)" },
                              playerID: dto.assist?.id)
        case .goal, .penaltyGoal:
            return MatchEvent(minute: minute, kind: kind, side: side,
                              player: dto.player?.name ?? "–",
                              detail: dto.assist?.name.map { "Assist: \($0)" },
                              playerID: dto.player?.id)
        default:
            return MatchEvent(minute: minute, kind: kind, side: side,
                              player: dto.player?.name ?? "–",
                              playerID: dto.player?.id)
        }
    }

    // MARK: - Heyətlər

    private static func mapLineups(_ dto: FixtureDTO) -> MatchLineups {
        let all = dto.lineups ?? []
        let events = dto.events ?? []
        let home = teamLineup(all.first { $0.team.id == dto.teams.home.id },
                              name: dto.teams.home.name, events: events)
        let away = teamLineup(all.first { $0.team.id == dto.teams.away.id },
                              name: dto.teams.away.name, events: events)
        return MatchLineups(home: home, away: away,
                            isConfirmed: !home.players.isEmpty && !away.players.isEmpty)
    }

    private static func teamLineup(_ dto: LineupDTO?, name: String, events: [EventDTO]) -> TeamLineup {
        guard let dto, let slots = dto.startXI, !slots.isEmpty else {
            return TeamLineup(teamName: name, formation: "", players: [])
        }

        // Qapıçı (1:1) birinci, sonra sətirlər müdafiədən hücuma, hər sətir soldan sağa.
        let ordered = slots.map(\.player).enumerated().sorted { lhs, rhs in
            let left = gridKey(lhs.element.grid)
            let right = gridKey(rhs.element.grid)
            if left.row != right.row { return left.row < right.row }
            if left.col != right.col { return left.col < right.col }
            return lhs.offset < rhs.offset
        }.map(\.element)

        let players = ordered.map { player -> LineupPlayer in
            let own = events.filter { $0.player?.id != nil && $0.player?.id == player.id }
            let goals = own.filter { isGoal($0) }.count
            let yellow = own.filter { $0.type.lowercased() == "card" && detailText($0) == "yellow card" }.count
            let sentOff = own.contains { $0.type.lowercased() == "card" && isRed($0) }
            return LineupPlayer(number: player.number ?? 0,
                                name: player.name ?? "–",
                                goals: goals,
                                yellowCards: yellow,
                                isSentOff: sentOff,
                                id: player.id)
        }
        return TeamLineup(teamName: name, formation: dto.formation ?? "", players: players)
    }

    private static func gridKey(_ grid: String?) -> (row: Int, col: Int) {
        let parts = grid?.split(separator: ":").compactMap { Int($0) } ?? []
        return parts.count == 2 ? (parts[0], parts[1]) : (Int.max, 0)
    }

    private static func detailText(_ event: EventDTO) -> String {
        (event.detail ?? "").lowercased()
    }

    /// Öz qapısına və buraxılmış penalti sayılmır.
    private static func isGoal(_ event: EventDTO) -> Bool {
        let detail = detailText(event)
        return event.type.lowercased() == "goal" && !detail.contains("own") && !detail.contains("missed")
    }

    private static func isRed(_ event: EventDTO) -> Bool {
        let detail = detailText(event)
        return detail.contains("red") || detail.contains("second")
    }

    // MARK: - Statistika

    private static func mapStats(_ teams: [TeamStatisticsDTO], homeID: Int?) -> [MatchStat] {
        guard teams.count == 2 else { return [] }
        let home = teams.first { $0.team.id == homeID } ?? teams[0]
        let away = teams.first { $0.team.id != homeID } ?? teams[1]

        let rows: [(api: String, title: String)] = [
            ("Ball Possession", "Possession"),
            ("Total Shots", "Shots"),
            ("Shots on Goal", "Shots on target"),
            ("Corner Kicks", "Corners"),
            ("Fouls", "Fouls"),
            ("Offsides", "Offsides"),
            ("Yellow Cards", "Yellow cards"),
            ("Red Cards", "Red cards"),
            ("Goalkeeper Saves", "Saves"),
            ("Total passes", "Passes")
        ]

        return rows.compactMap { row in
            let homeValue = statText(row.api, in: home)
            let awayValue = statText(row.api, in: away)
            if homeValue == nil && awayValue == nil { return nil }
            return MatchStat(title: row.title,
                             homeValue: homeValue ?? "0",
                             awayValue: awayValue ?? "0")
        }
    }

    /// Göstərici yoxdursa nil; var, amma boşdursa "0".
    private static func statText(_ type: String, in team: TeamStatisticsDTO) -> String? {
        guard let entry = team.statistics.first(where: { $0.type == type }) else { return nil }
        return entry.value?.displayText ?? "0"
    }

    // MARK: - H2H

    private static func mapHeadToHead(_ fixtures: [FixtureDTO], homeID: Int?) -> HeadToHead {
        var homeWins = 0
        var draws = 0
        var awayWins = 0
        var meetings: [(iso: String, match: H2HMatch)] = []

        for item in fixtures {
            guard let homeGoals = item.goals.home, let awayGoals = item.goals.away else { continue }
            guard case .finished = mapStatus(item) else { continue }

            if homeGoals == awayGoals {
                draws += 1
            } else {
                let winnerID = homeGoals > awayGoals ? item.teams.home.id : item.teams.away.id
                if winnerID == homeID { homeWins += 1 } else { awayWins += 1 }
            }

            meetings.append((item.fixture.date,
                             H2HMatch(date: dayText(item.fixture.date),
                                      competition: item.league.name,
                                      homeTeam: item.teams.home.name,
                                      awayTeam: item.teams.away.name,
                                      homeScore: homeGoals,
                                      awayScore: awayGoals)))
        }

        let latest = meetings.sorted { $0.iso > $1.iso }.prefix(5).map { $0.match }
        return HeadToHead(homeWins: homeWins, draws: draws, awayWins: awayWins, meetings: Array(latest))
    }
}
