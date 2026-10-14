//
//  FootballEndpoint.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  FootballEndpoint.swift
//  FootballApp
//

import Foundation

enum FootballEndpoint: EndPoint {
    case fixtures(date: String, timezone: String)
    case fixture(id: Int)
    case headToHead(home: Int, away: Int, last: Int)

    var path: String {
        switch self {
        case .fixtures, .fixture: return "/fixtures"
        case .headToHead: return "/fixtures/headtohead"
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
        }
    }

    var requestBody: RequestBody? { nil }
    var requestAuth: Bool { true }
}