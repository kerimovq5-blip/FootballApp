//
//  MockMatchEvents.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//
import Foundation

/// API gələnə qədər test hadisələri. Canlı oyunda yalnız cari dəqiqəyə qədər olan hadisələr göstərilir.
enum MockMatchEvents {

    static func make(for match: Match) -> [MatchEvent] {
        guard match.status.hasStarted else { return [] }

        let now = currentMinute(of: match.status)
        let isArsenalMatch = match.home == "Arsenal" && match.away == "Aston Villa"
        let source = isArsenalMatch ? arsenalVsAstonVilla : generic(for: match, now: now)

        let events = source
            .filter { minuteValue($0.minute) <= now }
            .sorted { minuteValue($0.minute) < minuteValue($1.minute) }
        guard now > 45 else { return events }

        // Fasilə sətri: birinci yarının hadisələrindən sonra, o vaxtkı hesabla.
        let firstHalf = events.filter { firstNumber($0.minute) <= 45 }
        let secondHalf = events.filter { firstNumber($0.minute) > 45 }
        let homeGoals = firstHalf.filter { $0.kind.isGoal && $0.side == .home }.count
        let awayGoals = firstHalf.filter { $0.kind.isGoal && $0.side == .away }.count
        let halfTime = MatchEvent.halfTime(score: "\(homeGoals) - \(awayGoals)")
        return firstHalf + [halfTime] + secondHalf
    }

    // MARK: - Data

    private static let arsenalVsAstonVilla: [MatchEvent] = [
        MatchEvent(minute: "5'", kind: .goal, side: .home, player: "Aubameyang", detail: "Assist: Saka"),
        MatchEvent(minute: "21'", kind: .yellowCard, side: .home, player: "Dani Ceballos"),
        MatchEvent(minute: "60'", kind: .substitution, side: .away, player: "El Ghazi", detail: "Out: Traore"),
        MatchEvent(minute: "63'", kind: .ownGoal, side: .home, player: "Konsa"),
        MatchEvent(minute: "71'", kind: .substitution, side: .home, player: "Nketiah", detail: "Out: Lacazette")
    ]

    /// Hesaba uyğun, cari dəqiqəyə qədər paylanmış ümumi hadisələr.
    private static func generic(for match: Match, now: Int) -> [MatchEvent] {
        var events: [MatchEvent] = []

        let homeGoals = match.homeScore ?? 0
        for index in 0..<homeGoals {
            let minute = max(1, now * (2 * index + 1) / (2 * homeGoals))
            events.append(MatchEvent(minute: "\(minute)'", kind: .goal, side: .home, player: "Player 9"))
        }

        let awayGoals = match.awayScore ?? 0
        for index in 0..<awayGoals {
            let minute = max(1, now * (2 * index + 2) / (2 * awayGoals + 1))
            events.append(MatchEvent(minute: "\(minute)'", kind: .goal, side: .away, player: "Player 10"))
        }

        if now > 25 {
            events.append(MatchEvent(minute: "\(now * 3 / 5)'", kind: .yellowCard, side: .home, player: "Player 4"))
        }
        if now > 40 {
            events.append(MatchEvent(minute: "\(now * 4 / 5)'", kind: .yellowCard, side: .away, player: "Player 6"))
        }
        return events
    }

    // MARK: - Minute helpers

    private static func currentMinute(of status: MatchStatus) -> Int {
        switch status {
        case .live(let minute): return minuteValue(minute)
        case .finished: return 90
        case .scheduled: return 0
        }
    }

    /// "63'" → 63, "90+5'" → 95
    private static func minuteValue(_ text: String) -> Int {
        numbers(in: text).reduce(0, +)
    }

    /// "45+2'" → 45 (hansı yarıya aid olduğunu təyin etmək üçün)
    private static func firstNumber(_ text: String) -> Int {
        numbers(in: text).first ?? 0
    }

    private static func numbers(in text: String) -> [Int] {
        text.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
    }
}
