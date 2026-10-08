//
//  MatchNotification.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import Foundation

struct MatchNotification {
    let id: String
    let matchID: Int
    let icon: String
    let title: String
    let message: String
    /// Sağ tərəfdə göstərilən qısa vaxt: "5'", "HT", "22:00".
    let time: String
}

/// Bir oyunun bildirişləri (ən yenisi birinci).
struct MatchNotificationGroup {
    let matchID: Int
    let matchTitle: String
    let competition: String
    let items: [MatchNotification]
}
