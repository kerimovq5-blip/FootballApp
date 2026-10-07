//
//  MatchEvent.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import Foundation

struct MatchEvent {

    enum Kind {
        case goal
        case penaltyGoal
        case ownGoal
        case yellowCard
        case redCard
        case substitution
        case halfTime

        var title: String {
            switch self {
            case .goal: return "Goal"
            case .penaltyGoal: return "Penalty goal"
            case .ownGoal: return "Own goal"
            case .yellowCard: return "Yellow card"
            case .redCard: return "Red card"
            case .substitution: return "Substitution"
            case .halfTime: return "Half time"
            }
        }

        var icon: String {
            switch self {
            case .goal, .penaltyGoal, .ownGoal: return "⚽"
            case .yellowCard: return "🟨"
            case .redCard: return "🟥"
            case .substitution: return "🔄"
            case .halfTime: return ""
            }
        }

        var isGoal: Bool {
            switch self {
            case .goal, .penaltyGoal, .ownGoal: return true
            default: return false
            }
        }
    }

    enum Side {
        case home
        case away
    }

    /// "5'", "45+2'" kimi.
    let minute: String
    let kind: Kind
    /// Hadisənin göstəriləcəyi tərəf. Qolda qolu qazanan komanda (öz qapısına vuruş da bura aiddir).
    let side: Side
    let player: String
    /// "Assist: Saka", "Out: Traore" kimi əlavə məlumat.
    var detail: String? = nil

    static func halfTime(score: String) -> MatchEvent {
        MatchEvent(minute: "HT", kind: .halfTime, side: .home, player: "", detail: score)
    }
}
