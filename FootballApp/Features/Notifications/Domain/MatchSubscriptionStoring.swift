//
//  MatchSubscriptionStoring.swift
//  FootballApp
//

import Foundation

/// İzlənən (zəngi açılmış) oyunların id-ləri.
protocol MatchSubscriptionStoring: AnyObject {
    var subscribedMatchIDs: Set<Int> { get }
    func isSubscribed(_ matchID: Int) -> Bool
    /// Oyunun bildirişini açıb-söndürür və yeni vəziyyəti qaytarır.
    @discardableResult
    func toggle(_ matchID: Int) -> Bool
    func clear()
}
