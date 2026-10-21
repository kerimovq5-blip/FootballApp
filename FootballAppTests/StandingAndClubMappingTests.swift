//
//  StandingAndClubMappingTests.swift
//  FootballAppTests
//

import Testing
@testable import FootballApp

@Suite("Mapper: turnir cədvəli")
@MainActor
struct StandingsMappingTests {

    /// Liverpool 1-ci (ÇL zonası), Arsenal 2-ci, Southampton 20-ci (aşağı liqa zonası, Home/Away yoxdur).
    private static func table() -> StandingsDTO {
        TestData.standings([
            TestData.row(rank: 1, teamID: 1, name: "Liverpool",
                         description: "Promotion - Champions League (League phase: )",
                         all: TestData.record(win: 10, draw: 2, lose: 1, scored: 30, conceded: 10),
                         home: TestData.record(win: 4, draw: 1, lose: 1, scored: 12, conceded: 6),
                         away: TestData.record(win: 6, draw: 1, lose: 0, scored: 18, conceded: 4)),
            TestData.row(rank: 2, teamID: 2, name: "Arsenal",
                         all: TestData.record(win: 9, draw: 3, lose: 1, scored: 25, conceded: 9),
                         home: TestData.record(win: 6, draw: 0, lose: 0, scored: 15, conceded: 3),
                         away: TestData.record(win: 3, draw: 3, lose: 1, scored: 10, conceded: 6)),
            TestData.row(rank: 20, teamID: 3, name: "Southampton",
                         description: "Relegation - Championship",
                         all: TestData.record(win: 1, draw: 2, lose: 10, scored: 8, conceded: 30))
        ])
    }

    @Test("Ümumi cədvəl: yer, zona, xal və qol fərqi")
    func allTable() throws {
        let rows = APIFootballMapper.standings(from: [Self.table()], filter: .all)
        try #require(rows.count == 3)

        #expect(rows.map(\.position) == [1, 2, 20])
        #expect(rows.map(\.zone) == [.championsLeague, .none, .relegation])
        #expect(rows[0].teamName == "Liverpool")
        #expect(rows[0].points == 32)
        #expect(rows[0].goalDifference == 20)
        #expect(rows[0].played == 13)
        #expect(rows[0].teamID == 1)
    }

    @Test("Ev cədvəli ev nəticələrinə görə yenidən sıralanır, zona rəngi olmur")
    func homeTable() {
        let rows = APIFootballMapper.standings(from: [Self.table()], filter: .home)
        #expect(rows.map(\.teamName) == ["Arsenal", "Liverpool", "Southampton"])
        #expect(rows.map(\.position) == [1, 2, 3])
        #expect(rows.allSatisfy { $0.zone == .none })
    }

    @Test("Ev/səfər qeydi yoxdursa ümumi nəticə götürülür")
    func missingHomeRecordFallsBack() throws {
        let rows = APIFootballMapper.standings(from: [Self.table()], filter: .away)
        let southampton = try #require(rows.first { $0.teamName == "Southampton" })
        #expect(southampton.played == 13)
        #expect(southampton.points == 5)
    }

    @Test("Xal bərabər olanda əvvəl qol fərqi, sonra vurulan qol həlledicidir")
    func tieBreakers() {
        let dto = TestData.standings([
            TestData.row(rank: 1, teamID: 1, name: "A",
                         all: TestData.record(win: 0, draw: 0, lose: 0, scored: 0, conceded: 0),
                         home: TestData.record(win: 3, draw: 0, lose: 0, scored: 5, conceded: 1)),   // +4
            TestData.row(rank: 2, teamID: 2, name: "B",
                         all: TestData.record(win: 0, draw: 0, lose: 0, scored: 0, conceded: 0),
                         home: TestData.record(win: 3, draw: 0, lose: 0, scored: 9, conceded: 4)),   // +5
            TestData.row(rank: 3, teamID: 3, name: "C",
                         all: TestData.record(win: 0, draw: 0, lose: 0, scored: 0, conceded: 0),
                         home: TestData.record(win: 3, draw: 0, lose: 0, scored: 7, conceded: 3))    // +4, çox qol
        ])
        let rows = APIFootballMapper.standings(from: [dto], filter: .home)
        #expect(rows.map(\.teamName) == ["B", "C", "A"])
    }

    @Test("Cavab boşdursa cədvəl boşdur")
    func emptyResponse() {
        #expect(APIFootballMapper.standings(from: [], filter: .all).isEmpty)
    }
}

@Suite("Mapper: klub səhifəsi")
@MainActor
struct ClubDetailMappingTests {

    private func club(fixtures: [FixtureDTO] = [],
                      standings: [StandingsDTO] = [],
                      squad: [SquadDTO] = []) -> ClubDetailContent {
        APIFootballMapper.clubDetail(reference: ClubReference(name: "Arsenal"),
                                     team: TestData.team(),
                                     fixtures: fixtures,
                                     standingDTOs: standings,
                                     squad: squad)
    }

    private func oneRowTable(leagueID: Int, name: String, country: String?) -> StandingsDTO {
        TestData.standings(
            [TestData.row(rank: 1, teamID: 10, name: "Arsenal",
                          all: TestData.record(win: 1, draw: 0, lose: 0, scored: 2, conceded: 0))],
            leagueID: leagueID, name: name, country: country
        )
    }

    @Test("Daxili liqa Avropa turnirindən əvvəl gəlir, \"World\" Europe kimi yazılır")
    func tablesOrder() throws {
        let content = club(standings: [
            oneRowTable(leagueID: 2, name: "UEFA Champions League", country: "World"),
            oneRowTable(leagueID: 39, name: "Premier League", country: "England")
        ])
        #expect(content.tables.map(\.league.name) == ["Premier League", "UEFA Champions League"])
        try #require(content.tables.count == 2)
        #expect(content.tables[1].league.country == "Europe")
        #expect(content.profile.competitions == ["Premier League", "UEFA Champions League"])
    }

    @Test("Nəticələr ən yenisi birinci, gələcək oyunlar ən yaxını birinci")
    func matchesOrder() {
        let content = club(fixtures: [
            TestData.fixture(id: 1, date: "2024-09-01T12:00:00+00:00", status: "FT"),
            TestData.fixture(id: 2, date: "2024-10-01T12:00:00+00:00", status: "FT"),
            TestData.fixture(id: 3, date: "2024-12-01T12:00:00+00:00", status: "NS"),
            TestData.fixture(id: 4, date: "2024-11-01T12:00:00+00:00", status: "NS")
        ])
        #expect(content.results.map(\.matchID) == [2, 1])
        #expect(content.upcoming.map(\.matchID) == [4, 3])
        #expect(content.results.allSatisfy { $0.statusText == "FT" })
    }

    @Test("Profil komanda məlumatından qurulur")
    func profile() {
        let content = club()
        #expect(content.profile.name == "Arsenal")
        #expect(content.profile.country == "England")
        #expect(content.profile.founded == 1886)
        #expect(content.profile.stadium == "Emirates Stadium")
    }

    @Test("Heyətdə mövqelər çevrilir, naməlum mövqe hücumçu sayılır")
    func squadPositions() {
        let squad = SquadDTO(players: [
            SquadDTO.Player(id: 1, name: "Raya", age: 29, number: 22, position: "Goalkeeper"),
            SquadDTO.Player(id: 2, name: "Saliba", age: 23, number: 2, position: "Defender"),
            SquadDTO.Player(id: 3, name: "Rice", age: 25, number: 41, position: "Midfielder"),
            SquadDTO.Player(id: 4, name: "Saka", age: nil, number: nil, position: "Attacker")
        ])
        let players = club(squad: [squad]).squad
        #expect(players.map(\.position) == [.goalkeeper, .defender, .midfielder, .forward])
        #expect(players.last?.age == 0)
        #expect(players.last?.number == 0)
    }
}
