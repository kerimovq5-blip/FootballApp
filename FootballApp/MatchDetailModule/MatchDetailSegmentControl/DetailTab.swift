import UIKit

enum MatchDetailsTab: CaseIterable {
    case matchDetail
    case statistics
    case lineUp
    case h2h

    var title: String {
        switch self {
        case .matchDetail: return "Match Detail"
        case .statistics: return "Statistics"
        case .lineUp: return "Line Up"
        case .h2h: return "H2H"
        }
    }
}
