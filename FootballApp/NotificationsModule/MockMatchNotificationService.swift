//
//  MockMatchNotificationService.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

protocol MatchNotificationProviding {
    /// Yalnız verilən (bildirişi açılmış) oyunların bildirişləri qaytarılır.
    func fetchNotifications(matchIDs: Set<Int>, completion: @escaping ([MatchNotificationGroup]) -> Void)
}

/// Real API (və ya push) hazır olanda bu tipin yerinə başqa implementasiya qoyulacaq.
struct MockMatchNotificationService: MatchNotificationProviding {

    func fetchNotifications(matchIDs: Set<Int>, completion: @escaping ([MatchNotificationGroup]) -> Void) {
        var groups: [MatchNotificationGroup] = []

        for league in MockData.leagues {
            for match in league.matches where matchIDs.contains(match.id) {
                groups.append(MatchNotificationGroup(
                    matchID: match.id,
                    matchTitle: "\(match.home) vs \(match.away)",
                    competition: league.name,
                    items: MockMatchNotificationService.makeNotifications(for: match)
                ))
            }
        }
        completion(groups)
    }

    // MARK: - Mock generation

    /// Oyunun hadisələrindən (MockMatchEvents) bildirişlər düzəldir.
    private static func makeNotifications(for match: Match) -> [MatchNotification] {
        guard match.status.hasStarted else {
            return [MatchNotification(
                id: "\(match.id)-kickoff-soon",
                matchID: match.id,
                icon: "⏰",
                title: "Kick-off reminder",
                message: "\(match.home) vs \(match.away) starts at \(match.status.displayText).",
                time: match.status.displayText
            )]
        }

        var items = [MatchNotification(
            id: "\(match.id)-started",
            matchID: match.id,
            icon: "🟢",
            title: "Match started",
            message: "\(match.home) vs \(match.away) has kicked off.",
            time: "KO"
        )]

        var homeGoals = 0
        var awayGoals = 0

        for (index, event) in MockMatchEvents.make(for: match).enumerated() {
            let team = event.side == .home ? match.home : match.away
            let id = "\(match.id)-event-\(index)"

            switch event.kind {
            case .goal, .penaltyGoal, .ownGoal:
                if event.side == .home { homeGoals += 1 } else { awayGoals += 1 }
                let score = "\(match.home) \(homeGoals) - \(awayGoals) \(match.away)"
                let title: String
                switch event.kind {
                case .penaltyGoal: title = "Penalty goal! \(team)"
                case .ownGoal: title = "Own goal! \(team) score"
                default: title = "Goal! \(team)"
                }
                items.append(MatchNotification(
                    id: id, matchID: match.id, icon: "⚽", title: title,
                    message: "\(event.player) \(event.minute) · \(score)", time: event.minute
                ))

            case .yellowCard, .redCard:
                items.append(MatchNotification(
                    id: id, matchID: match.id, icon: event.kind.icon, title: event.kind.title,
                    message: "\(event.player) (\(team)) \(event.minute)", time: event.minute
                ))

            case .substitution:
                let detail = event.detail.map { " · \($0)" } ?? ""
                items.append(MatchNotification(
                    id: id, matchID: match.id, icon: event.kind.icon, title: "Substitution · \(team)",
                    message: "\(event.player) \(event.minute)\(detail)", time: event.minute
                ))

            case .halfTime:
                let score = event.detail ?? ""
                items.append(MatchNotification(
                    id: id, matchID: match.id, icon: "⏱", title: "Half time",
                    message: "\(match.home) \(score) \(match.away)", time: "HT"
                ))
            }
        }

        // Ən yeni bildiriş birinci.
        return items.reversed()
    }
}
