import Foundation

/// Oyun statistikasının bir sətri: "Possession  58% | 42%".
struct MatchStat {
    let title: String
    let homeValue: String
    let awayValue: String
}

struct MatchDetailData {
    let competitionName: String
    let homeName: String
    let awayName: String
    /// Loqolar ekranda ayrıca yüklənir, data onları gözləmir.
    let homeCrestURL: String?
    let awayCrestURL: String?
    let score: String
    let minuteOrStatus: String
    let hasStarted: Bool
    let stats: [MatchStat]
    let events: [MatchEvent]
    let lineups: MatchLineups
    let headToHead: HeadToHead
}
