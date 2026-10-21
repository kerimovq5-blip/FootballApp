//
//  MatchDetailMappingTests.swift
//  FootballAppTests
//

import Testing
@testable import FootballApp

@Suite("Mapper: oyun detalı")
@MainActor
struct MatchDetailMappingTests {

    private func detail(_ fixture: FixtureDTO, h2h: [FixtureDTO] = []) -> MatchDetailData {
        APIFootballMapper.matchDetail(fixture: fixture, headToHead: h2h, homeCrest: nil, awayCrest: nil)
    }

    // MARK: - Hesab

    @Test("Bitmiş oyunda hesab və FT göstərilir")
    func finishedScore() {
        let data = detail(TestData.fixture(status: "FT", homeGoals: 2, awayGoals: 1))
        #expect(data.score == "2 - 1")
        #expect(data.minuteOrStatus == "FT")
        #expect(data.hasStarted)
    }

    @Test("Başlamamış oyunda hesab yerinə başlama vaxtı göstərilir")
    func notStartedScore() {
        let data = detail(TestData.fixture(date: "invalid", status: "NS", homeGoals: nil, awayGoals: nil))
        #expect(data.score == "--:--")
        #expect(data.minuteOrStatus == "Not started")
        #expect(!data.hasStarted)
    }

    // MARK: - Hadisələr

    @Test("Qol: oyunçu, assist, dəqiqə və tərəf düzgün götürülür")
    func goal() throws {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Goal", detail: "Normal Goal", minute: 23, teamID: 10,
                           player: "Saka", assist: "Odegaard")
        ])
        let event = try #require(detail(fixture).events.first)
        #expect(event.kind == .goal)
        #expect(event.side == .home)
        #expect(event.minute == "23'")
        #expect(event.player == "Saka")
        #expect(event.detail == "Assist: Odegaard")
    }

    @Test("Öz qapısına qol rəqib komandanın tərəfində göstərilir")
    func ownGoalSwitchesSide() throws {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Goal", detail: "Own Goal", teamID: 10)
        ])
        let event = try #require(detail(fixture).events.first)
        #expect(event.kind == .ownGoal)
        #expect(event.side == .away)
    }

    @Test("Penalti qolu ayrıca növdür")
    func penaltyGoal() throws {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Goal", detail: "Penalty", teamID: 20)
        ])
        let event = try #require(detail(fixture).events.first)
        #expect(event.kind == .penaltyGoal)
        #expect(event.side == .away)
    }

    @Test("Buraxılmış penalti və tanınmayan hadisələr göstərilmir")
    func skippedEvents() {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Goal", detail: "Missed Penalty"),
            TestData.event(type: "Var", detail: "Goal cancelled")
        ])
        #expect(detail(fixture).events.isEmpty)
    }

    @Test("Kartlar: sarı, qırmızı və ikinci sarı (qırmızı sayılır)")
    func cards() {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Card", detail: "Yellow Card"),
            TestData.event(type: "Card", detail: "Red Card"),
            TestData.event(type: "Card", detail: "Second Yellow card")
        ])
        #expect(detail(fixture).events.map(\.kind) == [.yellowCard, .redCard, .redCard])
    }

    @Test("Dəyişiklik: əsas ad girən, detal çıxan oyunçudur")
    func substitution() throws {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "subst", detail: "Substitution 1", player: "Martinelli", assist: "Trossard")
        ])
        let event = try #require(detail(fixture).events.first)
        #expect(event.kind == .substitution)
        #expect(event.player == "Trossard")
        #expect(event.detail == "Out: Martinelli")
    }

    @Test("Əlavə dəqiqə 90+3' kimi yazılır")
    func extraMinute() throws {
        let fixture = TestData.fixture(events: [
            TestData.event(type: "Goal", detail: "Normal Goal", minute: 90, extra: 3)
        ])
        let event = try #require(detail(fixture).events.first)
        #expect(event.minute == "90+3'")
    }

    @Test("Fasilə xətti ikinci yarının ilk hadisəsindən əvvəl qoyulur")
    func halftimeInserted() throws {
        let fixture = TestData.fixture(
            halftime: FixtureDTO.Goals(home: 1, away: 0),
            events: [
                TestData.event(type: "Goal", detail: "Normal Goal", minute: 30),
                TestData.event(type: "Goal", detail: "Normal Goal", minute: 60)
            ]
        )
        let events = detail(fixture).events
        #expect(events.map(\.kind) == [.goal, .halfTime, .goal])
        try #require(events.count == 3)
        #expect(events[1].detail == "1 - 0")
    }

    @Test("İkinci yarıda hadisə yoxdursa fasilə xətti sona əlavə olunur")
    func halftimeAppended() {
        let fixture = TestData.fixture(
            halftime: FixtureDTO.Goals(home: 0, away: 0),
            events: [TestData.event(type: "Card", detail: "Yellow Card", minute: 20)]
        )
        #expect(detail(fixture).events.map(\.kind) == [.yellowCard, .halfTime])
    }

    // MARK: - Statistika

    @Test("Statistika ev sahibinin id-sinə görə düzülür, olmayan göstərici atılır")
    func stats() throws {
        let fixture = TestData.fixture(statistics: [
            // Qəsdən əvvəlcə qonaq komanda gəlir.
            TestData.stats(teamID: 20, [
                (type: "Ball Possession", value: .text("45%")),
                (type: "Total Shots", value: .number(8)),
                (type: "Fouls", value: nil)
            ]),
            TestData.stats(teamID: 10, [
                (type: "Ball Possession", value: .text("55%")),
                (type: "Total Shots", value: .number(12)),
                (type: "Fouls", value: .number(3))
            ])
        ])
        let stats = detail(fixture).stats
        #expect(stats.map(\.title) == ["Possession", "Shots", "Fouls"])
        try #require(stats.count == 3)
        #expect(stats[0].homeValue == "55%")
        #expect(stats[0].awayValue == "45%")
        #expect(stats[1].homeValue == "12")
        #expect(stats[2].awayValue == "0")
    }

    @Test("Bir komandanın statistikası varsa heç nə göstərilmir")
    func statsNeedBothTeams() {
        let fixture = TestData.fixture(statistics: [
            TestData.stats(teamID: 10, [(type: "Total Shots", value: .number(5))])
        ])
        #expect(detail(fixture).stats.isEmpty)
    }

    // MARK: - Heyətlər

    @Test("Heyət: qapıçı birinci, sonra xətlər müdafiədən hücuma, soldan sağa")
    func lineupOrder() {
        let home = TestData.lineup(teamID: 10, players: [
            (id: 9, name: "Forward", number: 9, grid: "3:1"),
            (id: 3, name: "Right Back", number: 3, grid: "2:2"),
            (id: 1, name: "Keeper", number: 1, grid: "1:1"),
            (id: 2, name: "Left Back", number: 2, grid: "2:1")
        ])
        let away = TestData.lineup(teamID: 20, players: [(id: 50, name: "Away Keeper", number: 1, grid: "1:1")])
        let lineups = detail(TestData.fixture(lineups: [home, away])).lineups

        #expect(lineups.home.players.map(\.name) == ["Keeper", "Left Back", "Right Back", "Forward"])
        #expect(lineups.home.formation == "4-3-3")
        #expect(lineups.away.teamName == "Chelsea")
        #expect(lineups.isConfirmed)
    }

    @Test("Heyətdə qol, sarı kart və qırmızı kart oyunçuya yazılır")
    func lineupPlayerEvents() throws {
        let home = TestData.lineup(teamID: 10, players: [
            (id: 9, name: "Forward", number: 9, grid: "3:1"),
            (id: 3, name: "Right Back", number: 3, grid: "2:2")
        ])
        let away = TestData.lineup(teamID: 20, players: [(id: 50, name: "Away Keeper", number: 1, grid: "1:1")])
        let fixture = TestData.fixture(
            events: [
                TestData.event(type: "Goal", detail: "Normal Goal", playerID: 9, player: "Forward"),
                TestData.event(type: "Goal", detail: "Own Goal", playerID: 9, player: "Forward"),
                TestData.event(type: "Card", detail: "Yellow Card", playerID: 3, player: "Right Back"),
                TestData.event(type: "Card", detail: "Second Yellow card", playerID: 3, player: "Right Back")
            ],
            lineups: [home, away]
        )
        let players = detail(fixture).lineups.home.players
        let forward = try #require(players.first { $0.name == "Forward" })
        let back = try #require(players.first { $0.name == "Right Back" })

        #expect(forward.goals == 1)       // öz qapısına qol sayılmır
        #expect(back.yellowCards == 1)
        #expect(back.isSentOff)
        #expect(!forward.isSentOff)
    }

    @Test("Bir komandanın heyəti yoxdursa heyət təsdiqlənməmiş sayılır")
    func lineupNotConfirmed() {
        let home = TestData.lineup(teamID: 10, players: [(id: 1, name: "Keeper", number: 1, grid: "1:1")])
        let lineups = detail(TestData.fixture(lineups: [home])).lineups
        #expect(!lineups.isConfirmed)
        #expect(lineups.away.players.isEmpty)
        #expect(lineups.away.teamName == "Chelsea")
    }

    // MARK: - H2H

    @Test("H2H: qələbələr ev/qonaq yerindən asılı olmayaraq komandaya görə sayılır")
    func headToHeadCounts() {
        let h2h = [
            // Arsenal evdə qalib
            TestData.fixture(id: 101, date: "2024-01-10T12:00:00+00:00", homeID: 10, homeName: "Arsenal",
                             awayID: 20, awayName: "Chelsea", homeGoals: 2, awayGoals: 0),
            // Chelsea evdə qalib
            TestData.fixture(id: 102, date: "2024-02-10T12:00:00+00:00", homeID: 20, homeName: "Chelsea",
                             awayID: 10, awayName: "Arsenal", homeGoals: 1, awayGoals: 0),
            // Arsenal səfərdə qalib
            TestData.fixture(id: 103, date: "2024-03-10T12:00:00+00:00", homeID: 20, homeName: "Chelsea",
                             awayID: 10, awayName: "Arsenal", homeGoals: 0, awayGoals: 3),
            // Heç-heçə
            TestData.fixture(id: 104, date: "2024-04-10T12:00:00+00:00", homeGoals: 1, awayGoals: 1),
            // Hələ oynanmayıb, sayılmamalıdır
            TestData.fixture(id: 105, date: "2024-05-10T12:00:00+00:00", status: "NS",
                             homeGoals: nil, awayGoals: nil)
        ]
        let result = detail(TestData.fixture(), h2h: h2h).headToHead

        #expect(result.homeWins == 2)
        #expect(result.awayWins == 1)
        #expect(result.draws == 1)
        #expect(result.meetings.count == 4)
        #expect(result.meetings.first?.date == "10.04.2024")   // ən yenisi birinci
    }

    @Test("H2H: ən çox son 5 görüş göstərilir")
    func headToHeadLimit() {
        let h2h = (1...7).map { index in
            TestData.fixture(id: 200 + index, date: "2024-0\(index)-15T12:00:00+00:00", homeGoals: 1, awayGoals: 0)
        }
        let result = detail(TestData.fixture(), h2h: h2h).headToHead
        #expect(result.meetings.count == 5)
        #expect(result.homeWins == 7)
    }
}
