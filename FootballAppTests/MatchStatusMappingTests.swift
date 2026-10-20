//
//  MatchStatusMappingTests.swift
//  FootballAppTests
//

import Testing
@testable import FootballApp

@Suite("Mapper: oyun statusu")
@MainActor
struct MatchStatusMappingTests {

    @Test("Bitmiş oyun kodları FT kimi göstərilir", arguments: ["FT", "AET", "PEN", "AWD", "WO"])
    func finished(code: String) {
        let status = APIFootballMapper.mapStatus(TestData.fixture(status: code))
        #expect(status.displayText == "FT")
        #expect(status.hasStarted)
        #expect(!status.isLive)
    }

    @Test("Canlı oyunda dəqiqə göstərilir")
    func liveMinute() {
        let status = APIFootballMapper.mapStatus(TestData.fixture(status: "2H", elapsed: 67))
        #expect(status.displayText == "67'")
        #expect(status.isLive)
        #expect(status.hasStarted)
    }

    @Test("Əlavə vaxt 45+2' kimi yazılır")
    func liveExtraTime() {
        let status = APIFootballMapper.mapStatus(TestData.fixture(status: "1H", elapsed: 45, extra: 2))
        #expect(status.displayText == "45+2'")
    }

    @Test("Dəqiqə gəlməyibsə LIVE yazılır")
    func liveWithoutMinute() {
        let status = APIFootballMapper.mapStatus(TestData.fixture(status: "LIVE", elapsed: nil))
        #expect(status.displayText == "LIVE")
    }

    @Test("Fasilə və penaltilər seriyası canlı sayılır")
    func breaks() {
        let halftime = APIFootballMapper.mapStatus(TestData.fixture(status: "HT"))
        let penalties = APIFootballMapper.mapStatus(TestData.fixture(status: "P"))
        #expect(halftime.displayText == "HT")
        #expect(halftime.isLive)
        #expect(penalties.displayText == "PEN")
    }

    @Test("Təxirə salınmış və ləğv olunmuş oyun başlamamış sayılır",
          arguments: ["PST", "CANC", "ABD", "SUSP", "INT"])
    func postponed(code: String) {
        let status = APIFootballMapper.mapStatus(TestData.fixture(status: code))
        #expect(status.displayText == code)
        #expect(!status.hasStarted)
    }

    @Test("Başlamamış oyunda başlama saatı HH:mm formatındadır")
    func kickoffTime() throws {
        let status = APIFootballMapper.mapStatus(
            TestData.fixture(date: "2024-10-19T12:00:00+00:00", status: "NS")
        )
        let text = Array(status.displayText)
        try #require(text.count == 5)
        #expect(text[2] == ":")
        #expect(!status.hasStarted)
    }

    @Test("Tarix oxunmursa --:-- göstərilir")
    func invalidDate() {
        let status = APIFootballMapper.mapStatus(TestData.fixture(date: "invalid", status: "NS"))
        #expect(status.displayText == "--:--")
    }

    @Test("Status gəlməyibsə oyun başlamamış sayılır")
    func missingStatus() {
        let status = APIFootballMapper.mapStatus(TestData.fixture(date: "invalid", status: nil))
        #expect(!status.hasStarted)
    }
}

@Suite("Mapper: Home liqaları")
@MainActor
struct HomeLeaguesMappingTests {

    @Test("Seçilmiş liqalar verilən sırada öndə gəlir")
    func allowedLeaguesFirst() {
        let fixtures = [
            TestData.fixture(id: 1, leagueID: 140, leagueName: "La Liga"),
            TestData.fixture(id: 2, leagueID: 39, leagueName: "Premier League"),
            TestData.fixture(id: 3, leagueID: 500, leagueName: "Other")
        ]
        let leagues = APIFootballMapper.leagues(from: fixtures, allowedIDs: [39, 140])
        #expect(leagues.map(\.id) == [39, 140, 500])
    }

    @Test("Oyunu olmayan seçilmiş liqa göstərilmir")
    func emptyAllowedLeagueSkipped() {
        let leagues = APIFootballMapper.leagues(from: [TestData.fixture(leagueID: 39)], allowedIDs: [140, 39])
        #expect(leagues.map(\.id) == [39])
    }

    @Test("Qalan liqalar oyun sayına görə, bərabər olanda id-yə görə sıralanır")
    func restOrdering() {
        let fixtures = [
            TestData.fixture(id: 1, leagueID: 300),
            TestData.fixture(id: 2, leagueID: 200),
            TestData.fixture(id: 3, leagueID: 200),
            TestData.fixture(id: 4, leagueID: 100)
        ]
        let leagues = APIFootballMapper.leagues(from: fixtures, allowedIDs: [])
        #expect(leagues.map(\.id) == [200, 100, 300])
    }

    @Test("Qalan liqaların sayı 15 ilə məhdudlaşır")
    func restLimitedTo15() {
        let fixtures = (1...20).map { TestData.fixture(id: $0, leagueID: 1000 + $0) }
        let leagues = APIFootballMapper.leagues(from: fixtures, allowedIDs: [])
        #expect(leagues.count == 15)
    }

    @Test("Liqa daxilində oyunlar vaxta görə sıralanır")
    func matchesSortedByDate() throws {
        let fixtures = [
            TestData.fixture(id: 2, date: "2024-10-19T18:00:00+00:00"),
            TestData.fixture(id: 1, date: "2024-10-19T12:00:00+00:00")
        ]
        let league = try #require(APIFootballMapper.leagues(from: fixtures, allowedIDs: [39]).first)
        #expect(league.matches.map(\.id) == [1, 2])
    }

    @Test("Oyun məlumatları düzgün köçürülür")
    func matchFields() throws {
        let fixture = TestData.fixture(id: 7, homeName: "Arsenal", awayName: "Chelsea", homeGoals: 2, awayGoals: 1)
        let league = try #require(APIFootballMapper.leagues(from: [fixture], allowedIDs: [39]).first)
        let match = try #require(league.matches.first)
        #expect(match.id == 7)
        #expect(match.home == "Arsenal")
        #expect(match.away == "Chelsea")
        #expect(match.homeScore == 2)
        #expect(match.awayScore == 1)
        #expect(league.name == "Premier League")
        #expect(league.country == "England")
    }

    @Test("Bayraq URL-dən emoji düzəlir, olmayanda 🌍 qoyulur")
    func flags() throws {
        let fixtures = [
            TestData.fixture(id: 1, leagueID: 39, flag: "https://media.api-sports.io/flags/gb-eng.svg"),
            TestData.fixture(id: 2, leagueID: 2, flag: nil)
        ]
        let leagues = APIFootballMapper.leagues(from: fixtures, allowedIDs: [39, 2])
        try #require(leagues.count == 2)
        #expect(leagues[0].flag == "🇬🇧")
        #expect(leagues[1].flag == "🌍")
    }
}
