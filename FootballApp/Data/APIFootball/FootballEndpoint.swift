//
//  FootballEndpoint.swift
//  FootballApp
//

import Foundation

enum FootballEndpoint: EndPoint {
    case fixtures(date: String, timezone: String)
    case fixture(id: Int)
    case headToHead(home: Int, away: Int, last: Int)
    case standings(league: Int, season: Int)
    case team(id: Int)
    case teamSearch(name: String)
    case teamFixtures(team: Int, season: Int)
    case teamStandings(team: Int, season: Int)
    case squad(team: Int)
    case player(id: Int, season: Int)
    case playerSearch(name: String)
    case topScorers(league: Int, season: Int)
    case topAssists(league: Int, season: Int)

    var path: String {
        switch self {
        case .fixtures, .fixture, .teamFixtures: return "/fixtures"
        case .headToHead: return "/fixtures/headtohead"
        case .standings, .teamStandings: return "/standings"
        case .team, .teamSearch: return "/teams"
        case .squad: return "/players/squads"
        case .player: return "/players"
        case .playerSearch: return "/players/profiles"
        case .topScorers: return "/players/topscorers"
        case .topAssists: return "/players/topassists"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .fixtures(let date, let timezone):
            return [URLQueryItem(name: "date", value: date),
                    URLQueryItem(name: "timezone", value: timezone)]
        case .fixture(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
        case .headToHead(let home, let away, let last):
            return [URLQueryItem(name: "h2h", value: "\(home)-\(away)"),
                    URLQueryItem(name: "last", value: "\(last)")]
        case .standings(let league, let season):
            return [URLQueryItem(name: "league", value: "\(league)"),
                    URLQueryItem(name: "season", value: "\(season)")]
        case .team(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
        case .teamSearch(let name):
            return [URLQueryItem(name: "search", value: name)]
        case .teamFixtures(let team, let season):
            return [URLQueryItem(name: "team", value: "\(team)"),
                    URLQueryItem(name: "season", value: "\(season)")]
        case .teamStandings(let team, let season):
            return [URLQueryItem(name: "team", value: "\(team)"),
                    URLQueryItem(name: "season", value: "\(season)")]
        case .squad(let team):
            return [URLQueryItem(name: "team", value: "\(team)")]
        case .player(let id, let season):
            return [URLQueryItem(name: "id", value: "\(id)"),
                    URLQueryItem(name: "season", value: "\(season)")]
        case .playerSearch(let name):
            return [URLQueryItem(name: "search", value: name)]
        case .topScorers(let league, let season), .topAssists(let league, let season):
            return [URLQueryItem(name: "league", value: "\(league)"),
                    URLQueryItem(name: "season", value: "\(season)")]
        }
    }

    var requestBody: RequestBody? { nil }
    var requestAuth: Bool { true }
}
