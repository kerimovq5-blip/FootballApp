//
//  HomeDay.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  HomeDay.swift
//  FootballApp
//

import Foundation

/// Home-da seçilə bilən gün. Pulsuz API planı yalnız bu üç günü verir.
enum HomeDay: CaseIterable {
    case yesterday, today, tomorrow

    var title: String {
        switch self {
        case .yesterday: return "Yesterday"
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        }
    }

    /// Bu günə nisbətən fərq: -1, 0, 1.
    var offset: Int {
        switch self {
        case .yesterday: return -1
        case .today: return 0
        case .tomorrow: return 1
        }
    }
}