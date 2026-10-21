//
//  TestData.swift
//  FootballAppTests
//
//  Testlər üçün DTO qurucuları. Hər parametrin default dəyəri var,
//  testdə yalnız yoxlanılan sahəni dəyişmək kifayətdir.
//

import Foundation
@testable import FootballApp

@MainActor
enum TestData {

    // MARK: - Oyun

    /// Default: Arsenal (id 10) – Chelsea (id 20), Premier League, bitmiş oyun, 0-0.
    static func fixture(
        id: Int = 1,
        date: String = "2024-10-19T12:00:00+00:00",
        status: String? = "FT",
        elapsed: Int? = nil,
        extra: Int? = nil,
        leagueID: Int = 39,
        leagueName: String = "Premier League",
        country: String? = "England",
        flag: String? = "https://media.api-sports.io/flags/gb-eng.svg",
        homeID: Int? = 10,
        homeName: String = "Arsenal",
        awayID: Int? = 20,
        awayName: String = "Chelsea",
        homeGoals: Int? = 0,
        awayGoals: Int? = 0,
        halftime: FixtureDTO.Goals? = nil,
        events: [EventDTO]? = nil,
        lineups: [LineupDTO]? = nil,
        statistics: [TeamStatisticsDTO]? = nil
    ) -> FixtureDTO {
        FixtureDTO(
            fixture: FixtureDTO.Info(
                id: id,
                date: date,
                status: FixtureDTO.Status(short: status, elapsed: elapsed, extra: extra)
            ),
            league: FixtureDTO.LeagueInfo(id: leagueID, name: leagueName, country: country, flag: flag),
            teams: FixtureDTO.Teams(
                home: FixtureDTO.Team(id: homeID, name: homeName, logo: nil),
                away: FixtureDTO.Team(id: awayID, name: awayName, logo: nil)
            ),
            goals: FixtureDTO.Goals(home: homeGoals, away: awayGoals),
            score: FixtureDTO.Score(halftime: halftime),
            events: events,
            lineups: lineups,
            statistics: statistics
        )
    }

    // MARK: - Hadisə

    /// Default: ev sahibinin (id 10) 10-cu dəqiqədə hadisəsi.
    static func event(
        type: String,
        detail: String? = nil,
        minute: Int? = 10,
        extra: Int? = nil,
        teamID: Int? = 10,
        playerID: Int? = nil,
        player: String? = "Player",
        assist: String? = nil
    ) -> EventDTO {
        EventDTO(
            time: EventDTO.Time(elapsed: minute, extra: extra),
            team: EventDTO.TeamRef(id: teamID, name: nil),
            player: EventDTO.PlayerRef(id: playerID, name: player),
            assist: assist.map { EventDTO.PlayerRef(id: nil, name: $0) },
            type: type,
            detail: detail
        )
    }

    // MARK: - Heyət

    static func lineup(
        teamID: Int,
        formation: String = "4-3-3",
        players: [(id: Int, name: String, number: Int, grid: String?)]
    ) -> LineupDTO {
        LineupDTO(
            team: LineupDTO.TeamRef(id: teamID, name: nil),
            formation: formation,
            startXI: players.map { item in
                LineupDTO.Slot(player: LineupDTO.Player(
                    id: item.id,
                    name: item.name,
                    number: item.number,
                    pos: nil,
                    grid: item.grid
                ))
            }
        )
    }

    // MARK: - Statistika

    static func stats(teamID: Int, _ entries: [(type: String, value: StatValue?)]) -> TeamStatisticsDTO {
        TeamStatisticsDTO(
            team: TeamStatisticsDTO.TeamRef(id: teamID),
            statistics: entries.map { TeamStatisticsDTO.Entry(type: $0.type, value: $0.value) }
        )
    }

    // MARK: - Cədvəl

    static func record(win: Int, draw: Int, lose: Int, scored: Int, conceded: Int) -> StandingsDTO.Record {
        StandingsDTO.Record(
            played: win + draw + lose,
            win: win,
            draw: draw,
            lose: lose,
            goals: StandingsDTO.Goals(scored: scored, conceded: conceded)
        )
    }

    static func row(
        rank: Int,
        teamID: Int,
        name: String,
        description: String? = nil,
        all: StandingsDTO.Record,
        home: StandingsDTO.Record? = nil,
        away: StandingsDTO.Record? = nil
    ) -> StandingsDTO.Row {
        StandingsDTO.Row(
            rank: rank,
            team: StandingsDTO.Team(id: teamID, name: name, logo: nil),
            description: description,
            all: all,
            home: home,
            away: away
        )
    }

    static func standings(
        _ rows: [StandingsDTO.Row],
        leagueID: Int = 39,
        name: String = "Premier League",
        country: String? = "England"
    ) -> StandingsDTO {
        StandingsDTO(league: StandingsDTO.Info(
            id: leagueID,
            name: name,
            country: country,
            flag: "https://media.api-sports.io/flags/gb-eng.svg",
            standings: [rows]
        ))
    }

    // MARK: - Klub

    static func team(id: Int = 10, name: String = "Arsenal") -> TeamInfoDTO {
        TeamInfoDTO(
            team: TeamInfoDTO.Team(id: id, name: name, country: "England", founded: 1886, national: false, logo: nil),
            venue: TeamInfoDTO.Venue(name: "Emirates Stadium", city: "London", capacity: 60_704)
        )
    }
}
