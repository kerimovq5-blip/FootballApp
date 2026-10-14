//
//  APIResponse.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  APIFootballModels.swift
//  FootballApp
//

import Foundation

// MARK: - Ümumi sarğı

/// API-Football hər cavabı `errors` və `response` ilə qaytarır. Xəta olanda da status 200 ola bilir.
struct APIResponse<Item: Decodable>: Decodable {
    let errors: APIErrors
    let response: [Item]

    private enum CodingKeys: String, CodingKey {
        case errors, response
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errors = (try? container.decode(APIErrors.self, forKey: .errors)) ?? APIErrors(messages: [])
        self.errors = errors

        if errors.messages.isEmpty {
            response = try container.decodeIfPresent([Item].self, forKey: .response) ?? []
        } else {
            response = (try? container.decode([Item].self, forKey: .response)) ?? []
        }
    }
}

/// `errors` xəta yoxdursa boş massiv `[]`, varsa `{ "plan": "..." }` obyekti olur.
struct APIErrors: Decodable {
    let messages: [String]

    init(messages: [String]) {
        self.messages = messages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dictionary = try? container.decode([String: String].self) {
            messages = dictionary.keys.sorted().compactMap { dictionary[$0] }
        } else if let array = try? container.decode([String].self) {
            messages = array
        } else {
            messages = ["Unexpected API error"]
        }
    }

    var message: String? {
        messages.isEmpty ? nil : messages.joined(separator: "\n")
    }
}

// MARK: - Oyun

struct FixtureDTO: Decodable {

    struct Info: Decodable {
        let id: Int
        let date: String
        let status: Status
    }

    struct Status: Decodable {
        let short: String?
        let elapsed: Int?
        let extra: Int?
    }

    struct LeagueInfo: Decodable {
        let id: Int
        let name: String
        let country: String?
        let flag: String?
    }

    struct Team: Decodable {
        let id: Int?
        let name: String
        let logo: String?
    }

    struct Teams: Decodable {
        let home: Team
        let away: Team
    }

    struct Goals: Decodable {
        let home: Int?
        let away: Int?
    }

    struct Score: Decodable {
        let halftime: Goals?
    }

    let fixture: Info
    let league: LeagueInfo
    let teams: Teams
    let goals: Goals
    let score: Score?

    // Yalnız `fixtures?id=` sorğusunda gəlir.
    let events: [EventDTO]?
    let lineups: [LineupDTO]?
    let statistics: [TeamStatisticsDTO]?
}

// MARK: - Hadisələr

struct EventDTO: Decodable {

    struct Time: Decodable {
        let elapsed: Int?
        let extra: Int?
    }

    struct TeamRef: Decodable {
        let id: Int?
        let name: String?
    }

    struct PlayerRef: Decodable {
        let id: Int?
        let name: String?
    }

    let time: Time
    let team: TeamRef
    /// Dəyişiklikdə oyundan çıxan oyunçu.
    let player: PlayerRef?
    /// Qolda assist verən, dəyişiklikdə oyuna girən oyunçu.
    let assist: PlayerRef?
    let type: String
    let detail: String?
}

// MARK: - Heyətlər

struct LineupDTO: Decodable {

    struct TeamRef: Decodable {
        let id: Int?
        let name: String?
    }

    struct Slot: Decodable {
        let player: Player
    }

    struct Player: Decodable {
        let id: Int?
        let name: String?
        let number: Int?
        let pos: String?
        /// "sətir:sütun", məs. "3:2" (1:1 qapıçıdır).
        let grid: String?
    }

    let team: TeamRef
    let formation: String?
    let startXI: [Slot]?
}

// MARK: - Statistika

struct TeamStatisticsDTO: Decodable {

    struct TeamRef: Decodable {
        let id: Int?
    }

    struct Entry: Decodable {
        let type: String
        let value: StatValue?
    }

    let team: TeamRef
    let statistics: [Entry]
}

/// Statistika dəyəri rəqəm (5), mətn ("42%") və ya null ola bilər.
enum StatValue: Decodable {
    case number(Double)
    case text(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let text = try? container.decode(String.self) {
            self = .text(text)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported stat value")
            )
        }
    }

    var displayText: String {
        switch self {
        case .number(let number):
            return number == number.rounded() ? "\(Int(number))" : String(format: "%.1f", number)
        case .text(let text):
            return text
        }
    }
}