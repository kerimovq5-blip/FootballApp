//
//  MatchDetailService.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import UIKit
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
        let started = match.status.hasStarted
        let empty = "–"

        return MatchDetailData(
            competitionName: league.name,
            homeName: match.home,
            awayName: match.away,
            homeCrest: crest(for: match.home),
            awayCrest: crest(for: match.away),
            // Başlamamış oyunda hesab əvəzinə start vaxtı göstərilir.
            score: started ? "\(match.homeScore ?? 0) - \(match.awayScore ?? 0)" : match.status.displayText,
            minuteOrStatus: started ? match.status.displayText : "Not started",
            hasStarted: started,
            stats: [
                .init(title: "Shooting", homeValue: started ? "8" : empty, awayValue: started ? "12" : empty),
                .init(title: "Attacks", homeValue: started ? "22" : empty, awayValue: started ? "29" : empty),
                .init(title: "Possession", homeValue: started ? "42" : empty, awayValue: started ? "58" : empty),
                .init(title: "Cards", homeValue: started ? "3" : empty, awayValue: started ? "5" : empty),
                .init(title: "Corners", homeValue: started ? "8" : empty, awayValue: started ? "7" : empty)
            ],
            events: MockMatchEvents.make(for: match),
            lineups: MockLineups.make(for: match),
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

    /// Assets-də "realmadrid" kimi adlı loqo varsa tapır; yoxdursa header baş hərfləri göstərir.
    private static func crest(for team: String) -> UIImage? {
        UIImage(named: team.lowercased().filter { $0.isLetter })
    }
}

