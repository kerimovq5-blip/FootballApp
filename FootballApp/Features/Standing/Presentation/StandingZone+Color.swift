//
//  StandingZone+Color.swift
//  FootballApp
//
//  Rəng ekranın işidir, ona görə domain modelində yox, burada saxlanılır.
//

import UIKit

extension StandingZone {

    var backgroundColor: UIColor {
        switch self {
        case .championsLeague: return UIColor(red: 0.09, green: 0.17, blue: 0.38, alpha: 1)
        case .relegation: return UIColor(red: 0.36, green: 0.11, blue: 0.08, alpha: 1)
        case .none: return .clear
        }
    }
}
