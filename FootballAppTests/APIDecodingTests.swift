//
//  APIDecodingTests.swift
//  FootballAppTests
//
//  API-Football-un real cavab formasına uyğun JSON-larla decode yoxlamaları.
//

import Foundation
import Testing
@testable import FootballApp

@Suite("JSON decode")
@MainActor
struct APIDecodingTests {

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    // MARK: - Cavab sarğısı

    @Test("Xəta yoxdursa `errors` boş massiv olur və cavab oxunur")
    func successResponse() throws {
        let json = """
        {
          "errors": [],
          "response": [{
            "team": { "id": 42, "name": "Arsenal", "country": "England",
                      "founded": 1886, "national": false, "logo": "https://media.api-sports.io/football/teams/42.png" },
            "venue": { "name": "Emirates Stadium", "city": "London", "capacity": 60704 }
          }]
        }
        """
        let response = try decode(APIResponse<TeamInfoDTO>.self, json)
        #expect(response.errors.message == nil)
        #expect(response.response.first?.team.name == "Arsenal")
        #expect(response.response.first?.venue?.capacity == 60704)
    }

    @Test("Xəta olanda `errors` obyekt olur və mesaj oxunur")
    func errorResponse() throws {
        let json = """
        {
          "errors": { "plan": "Free plans do not have access to this season, try from 2022 to 2024." },
          "response": []
        }
        """
        let response = try decode(APIResponse<FixtureDTO>.self, json)
        #expect(response.errors.message == "Free plans do not have access to this season, try from 2022 to 2024.")
        #expect(response.response.isEmpty)
    }

    @Test("Xəta olanda `response` səhv formada gəlsə də decode sınmır")
    func errorWithBrokenResponse() throws {
        let json = """
        { "errors": { "token": "Error/Missing application key." }, "response": "unexpected" }
        """
        let response = try decode(APIResponse<FixtureDTO>.self, json)
        #expect(response.errors.message == "Error/Missing application key.")
        #expect(response.response.isEmpty)
    }

    // MARK: - Oyun

    @Test("Oyun: əsas sahələr oxunur, detal sahələri olmayanda nil olur")
    func fixture() throws {
        let json = """
        {
          "fixture": { "id": 1208021, "date": "2024-10-19T14:00:00+00:00",
                       "status": { "long": "Match Finished", "short": "FT", "elapsed": 90, "extra": null } },
          "league": { "id": 39, "name": "Premier League", "country": "England",
                      "flag": "https://media.api-sports.io/flags/gb-eng.svg", "season": 2024 },
          "teams": { "home": { "id": 42, "name": "Arsenal", "logo": "a.png", "winner": true },
                     "away": { "id": 49, "name": "Chelsea", "logo": "c.png", "winner": false } },
          "goals": { "home": 2, "away": 1 },
          "score": { "halftime": { "home": 1, "away": 0 } }
        }
        """
        let dto = try decode(FixtureDTO.self, json)
        #expect(dto.fixture.id == 1208021)
        #expect(dto.fixture.status.short == "FT")
        #expect(dto.teams.home.name == "Arsenal")
        #expect(dto.goals.home == 2)
        #expect(dto.score?.halftime?.home == 1)
        #expect(dto.events == nil)
        #expect(dto.lineups == nil)
    }

    @Test("Başlamamış oyunda qollar null gəlir")
    func fixtureNotStarted() throws {
        let json = """
        {
          "fixture": { "id": 1, "date": "2024-10-20T16:30:00+00:00",
                       "status": { "short": "NS", "elapsed": null, "extra": null } },
          "league": { "id": 39, "name": "Premier League", "country": "England", "flag": null },
          "teams": { "home": { "id": 1, "name": "A", "logo": null },
                     "away": { "id": 2, "name": "B", "logo": null } },
          "goals": { "home": null, "away": null },
          "score": { "halftime": { "home": null, "away": null } }
        }
        """
        let dto = try decode(FixtureDTO.self, json)
        #expect(dto.goals.home == nil)
        #expect(dto.fixture.status.elapsed == nil)
        #expect(!APIFootballMapper.mapStatus(dto).hasStarted)
    }

    // MARK: - Cədvəl

    @Test("Cədvəl: qollar \"for\" və \"against\" açarlarından oxunur")
    func standings() throws {
        let json = """
        {
          "league": {
            "id": 39, "name": "Premier League", "country": "England",
            "flag": "https://media.api-sports.io/flags/gb-eng.svg",
            "standings": [[{
              "rank": 1,
              "team": { "id": 40, "name": "Liverpool", "logo": "l.png" },
              "description": "Promotion - Champions League (League phase: )",
              "all":  { "played": 13, "win": 10, "draw": 2, "lose": 1, "goals": { "for": 30, "against": 10 } },
              "home": { "played": 6,  "win": 4,  "draw": 1, "lose": 1, "goals": { "for": 12, "against": 6 } },
              "away": { "played": 7,  "win": 6,  "draw": 1, "lose": 0, "goals": { "for": 18, "against": 4 } }
            }]]
          }
        }
        """
        let dto = try decode(StandingsDTO.self, json)
        let row = try #require(dto.league.standings.first?.first)
        #expect(row.all.goals.scored == 30)
        #expect(row.all.goals.conceded == 10)
        #expect(row.home?.win == 4)
    }

    // MARK: - Statistika

    @Test("Statistika dəyəri rəqəm, mətn və ya null ola bilər")
    func statValues() throws {
        let json = """
        {
          "team": { "id": 42 },
          "statistics": [
            { "type": "Total Shots", "value": 12 },
            { "type": "Ball Possession", "value": "55%" },
            { "type": "Red Cards", "value": null },
            { "type": "expected_goals", "value": 1.75 }
          ]
        }
        """
        let dto = try decode(TeamStatisticsDTO.self, json)
        try #require(dto.statistics.count == 4)
        #expect(dto.statistics[0].value?.displayText == "12")
        #expect(dto.statistics[1].value?.displayText == "55%")
        #expect(dto.statistics[2].value == nil)
        #expect(dto.statistics[3].value?.displayText == "1.8")
    }
}
