//
//  Match.swift
//  FootballApp
//
//  Created by Servan on 29.09.26.
//
enum MatchStatus {
    case scheduled(kickoff: String)
    case live(minute: String)
    case finished

    var displayText: String {
        switch self {
        case .scheduled(let kickoff): return kickoff
        case .live(let minute): return minute
        case .finished: return "FT"
        }
    }

    var isLive: Bool {
        if case .live = self { return true }
        return false
    }
}

struct Match {
    let home: String
    let away: String
    let homeScore: Int?
    let awayScore: Int?
    let status: MatchStatus
}

struct League {
    let name: String
    let country: String
    let flag: String
    let matches: [Match]
}

enum MatchFilter: CaseIterable {
    case all
    case live

    var title: String {
        switch self {
        case .all: return "All"
        case .live: return "Live"
        }
    }
}
