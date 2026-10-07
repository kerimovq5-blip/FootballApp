//
//  MatchDetailService.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

protocol MatchDetailProviding {
    func fetchMatchDetail(id: Int, completion: @escaping (Result<MatchDetailData, Error>) -> Void)
}

/// Real API (NetworkManager) hazır olanda bu tipin yerinə başqa implementasiya qoyulacaq.
struct MockMatchDetailService: MatchDetailProviding {

    func fetchMatchDetail(id: Int, completion: @escaping (Result<MatchDetailData, Error>) -> Void) {
        let found = MockData.leagues.lazy
            .compactMap { league in
                league.matches.first { $0.id == id }.map { (league, $0) }
            }
            .first

        guard let (league, match) = found else {
            completion(.failure(LocalError.noData))
            return
        }
        completion(.success(Self.makeData(league: league, match: match)))
    }

    private static func makeData(league: League, match: Match) -> MatchDetailData {
        MatchDetailData(
            competitionName: league.name,
            homeName: match.home,
            awayName: match.away,
            homeCrest: nil,
            awayCrest: nil,
            score: "\(match.homeScore ?? 0) - \(match.awayScore ?? 0)",
            minuteOrStatus: match.status.displayText,
            stats: [
                .init(title: "Shooting", homeValue: "8", awayValue: "12"),
                .init(title: "Attacks", homeValue: "22", awayValue: "29"),
                .init(title: "Possession", homeValue: "42", awayValue: "58"),
                .init(title: "Cards", homeValue: "3", awayValue: "5"),
                .init(title: "Corners", homeValue: "8", awayValue: "7")
            ],
            formationName: "4-2-3-1",
            formation: [
                [.init(number: 1, name: "Leno")],
                [.init(number: 3, name: "Tierney"), .init(number: 22, name: "Pablo Mari"), .init(number: 16, name: "Holding"), .init(number: 2, name: "Bellerin")],
                [.init(number: 34, name: "Xhaka"), .init(number: 8, name: "Dani Ceballos")],
                [.init(number: 14, name: "Aubameyang"), .init(number: 9, name: "Lacazette"), .init(number: 7, name: "Saka")]
            ],
            headToHead: HeadToHead(
                homeWins: 4,
                draws: 3,
                awayWins: 3,
                meetings: [
                    .init(date: "12.03.2025", competition: "UCL", homeTeam: match.home, awayTeam: match.away, homeScore: 2, awayScore: 3),
                    .init(date: "05.11.2024", competition: "UCL", homeTeam: match.away, awayTeam: match.home, homeScore: 1, awayScore: 1)
                ]
            )
        )
    }
}
