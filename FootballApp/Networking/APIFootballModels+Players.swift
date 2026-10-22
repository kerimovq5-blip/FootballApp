//
//  APIFootballModels+Players.swift
//  FootballApp
//
//  `/players`, `/players/profiles`, `/players/topscorers`, `/players/topassists` cavabları.
//

import Foundation

// MARK: - Oyunçu

/// API bəzi rəqəmləri gah rəqəm (79), gah mətn ("79") kimi qaytarır. Hər ikisi oxunur,
/// oxunmayan dəyər nil olur və bütün cavabı sındırmır.
struct FlexibleInt: Codable {
    let value: Int?

    init(_ value: Int?) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Int.self) {
            value = number
        } else if let number = try? container.decode(Double.self) {
            value = Int(number.rounded())
        } else if let text = try? container.decode(String.self) {
            value = Int(text.filter { $0.isNumber })
        } else {
            value = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct PlayerDTO: Codable {
    let id: Int
    let name: String?
    let firstname: String?
    let lastname: String?
    let age: Int?
    let nationality: String?
    /// "180 cm"
    let height: String?
    /// Yalnız `/players/profiles` cavabında olur.
    let number: Int?
    let position: String?
    let photo: String?
}

/// `/players/profiles` (axtarış).
struct PlayerProfileDTO: Codable {
    let player: PlayerDTO
}

/// `/players`, `/players/topscorers` və `/players/topassists`: oyunçu + hər turnir üzrə statistika.
struct PlayerStatsDTO: Codable {

    struct Statistic: Codable {

        struct TeamRef: Codable {
            let id: Int?
            let name: String?
            let logo: String?
        }

        struct LeagueRef: Codable {
            let id: Int?
            let name: String?
            let country: String?
            let season: Int?
        }

        struct Games: Codable {
            // API-də söz belə yazılıb ("appearences").
            let appearences: FlexibleInt?
            let lineups: FlexibleInt?
            let minutes: FlexibleInt?
            let number: FlexibleInt?
            let position: String?
            /// "7.250000"
            let rating: String?
        }

        struct Shots: Codable {
            let total: FlexibleInt?
            let on: FlexibleInt?
        }

        struct Goals: Codable {
            let total: FlexibleInt?
            let conceded: FlexibleInt?
            let assists: FlexibleInt?
            let saves: FlexibleInt?
        }

        struct Passes: Codable {
            let total: FlexibleInt?
            let key: FlexibleInt?
            let accuracy: FlexibleInt?
        }

        struct Tackles: Codable {
            let total: FlexibleInt?
            let interceptions: FlexibleInt?
        }

        struct Duels: Codable {
            let total: FlexibleInt?
            let won: FlexibleInt?
        }

        struct Fouls: Codable {
            let drawn: FlexibleInt?
            let committed: FlexibleInt?
        }

        struct Cards: Codable {
            let yellow: FlexibleInt?
            let red: FlexibleInt?
        }

        struct Penalty: Codable {
            let scored: FlexibleInt?
            let saved: FlexibleInt?
        }

        let team: TeamRef?
        let league: LeagueRef?
        let games: Games?
        let shots: Shots?
        let goals: Goals?
        let passes: Passes?
        let tackles: Tackles?
        let duels: Duels?
        let fouls: Fouls?
        let cards: Cards?
        let penalty: Penalty?
    }

    let player: PlayerDTO
    let statistics: [Statistic]
}
