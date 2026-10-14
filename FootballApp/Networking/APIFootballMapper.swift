//
//  APIFootballMapper.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  APIFootballMapper.swift
//  FootballApp
//

import UIKit

enum APIFootballMapper {

    // MARK: - Home

    /// Oyunları liqalara görə qruplaşdırır; yalnız `allowedIDs`, həmin sıra ilə.
    static func leagues(from fixtures: [FixtureDTO], allowedIDs: [Int]) -> [League] {
        let grouped = Dictionary(grouping: fixtures, by: { $0.league.id })
        return allowedIDs.compactMap { id in
            guard let items = grouped[id], let first = items.first else { return nil }
            let matches = items
                .sorted { $0.fixture.date < $1.fixture.date }
                .map(mapMatch)
            return League(id: id,
                          name: first.league.name,
                          country: first.league.country ?? "",
                          flag: flag(for: first.league),
                          matches: matches)
        }
    }

    static func mapMatch(_ dto: FixtureDTO) -> Match {
        Match(id: dto.fixture.id,
              home: dto.teams.home.name,
              away: dto.teams.away.name,
              homeScore: dto.goals.home,
              awayScore: dto.goals.away,
              status: mapStatus(dto))
    }

    static func mapStatus(_ dto: FixtureDTO) -> MatchStatus {
        let status = dto.fixture.status
        switch status.short ?? "" {
        case "FT", "AET", "PEN", "AWD", "WO":
            return .finished
        case "1H", "2H", "ET", "LIVE":
            return .live(minute: minuteText(elapsed: status.elapsed, extra: status.extra))
        case "HT":
            return .live(minute: "HT")
        case "BT":
            return .live(minute: "BT")
        case "P":
            return .live(minute: "PEN")
        case "PST", "CANC", "ABD", "SUSP", "INT":
            return .scheduled(kickoff: status.short ?? "")
        default:
            return .scheduled(kickoff: kickoffText(dto.fixture.date))
        }
    }

    // MARK: - Match detail

    static func matchDetail(fixture dto: FixtureDTO,
                            headToHead h2hFixtures: [FixtureDTO],
                            homeCrest: UIImage?,
                            awayCrest: UIImage?) -> MatchDetailData {
        let current = mapMatch(dto)
        let started = current.status.hasStarted
        let homeID = dto.teams.home.id

        return MatchDetailData(
            competitionName: dto.league.name,
            homeName: dto.teams.home.name,
            awayName: dto.teams.away.name,
            homeCrest: homeCrest,
            awayCrest: awayCrest,
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
                              detail: dto.player?.name.map { "Out: \($0)" })
        case .goal, .penaltyGoal:
            return MatchEvent(minute: minute, kind: kind, side: side,
                              player: dto.player?.name ?? "–",
                              detail: dto.assist?.name.map { "Assist: \($0)" })
        default:
            return MatchEvent(minute: minute, kind: kind, side: side,
                              player: dto.player?.name ?? "–")
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
                                isSentOff: sentOff)
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

    private static func mapStats(_ teams: [TeamStatisticsDTO], homeID: Int?) -> [MatchStatsView.Stat] {
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
            return MatchStatsView.Stat(title: row.title,
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
                 crestImageName: nil,
                 played: record.played,
                 wins: record.win,
                 draws: record.draw,
                 losses: record.lose,
                 goalsFor: record.goals.scored,
                 goalsAgainst: record.goals.conceded,
                 zone: zone,
                 crestURL: row.team.logo)
    }

    /// API-nin izahından ("Promotion - Champions League...") zona rəngi.
    private static func mapZone(_ description: String?) -> StandingZone {
        let text = (description ?? "").lowercased()
        if text.contains("relegation") || text.contains("elimination") { return .relegation }
        if text.contains("champions league") { return .championsLeague }
        return .none
    }
    // MARK: - Köməkçilər

    private static func minuteText(elapsed: Int?, extra: Int?) -> String {
        guard let elapsed else { return "LIVE" }
        if let extra, extra > 0 { return "\(elapsed)+\(extra)'" }
        return "\(elapsed)'"
    }

    private static let isoParser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static func kickoffText(_ iso: String) -> String {
        isoParser.date(from: iso).map { timeFormatter.string(from: $0) } ?? "--:--"
    }

    private static func dayText(_ iso: String) -> String {
        isoParser.date(from: iso).map { dayFormatter.string(from: $0) } ?? ""
    }

    /// Liqanın bayraq şəklindən ("…/flags/gb-eng.svg") ölkə kodunu götürüb emoji bayraq düzəldir.
    private static func flag(for league: FixtureDTO.LeagueInfo) -> String {
        if let url = league.flag,
           let file = url.split(separator: "/").last,
           let code = file.split(separator: ".").first?.split(separator: "-").first,
           let emoji = emoji(forCountryCode: String(code)) {
            return emoji
        }
        return "🌍"
    }

    private static func emoji(forCountryCode code: String) -> String? {
        let upper = code.uppercased()
        guard upper.count == 2 else { return nil }
        var result = ""
        for scalar in upper.unicodeScalars {
            guard let flagScalar = UnicodeScalar(127397 + scalar.value) else { return nil }
            result.unicodeScalars.append(flagScalar)
        }
        return result
    }
}
