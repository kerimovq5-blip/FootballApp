import UIKit

struct MatchDetailData {
    let competitionName: String
    let homeName: String
    let awayName: String
    let homeCrest: UIImage?
    let awayCrest: UIImage?
    let score: String
    let minuteOrStatus: String
    let hasStarted: Bool
    let stats: [MatchStatsView.Stat]
    let events: [MatchEvent]
    let lineups: MatchLineups
    let headToHead: HeadToHead
}
