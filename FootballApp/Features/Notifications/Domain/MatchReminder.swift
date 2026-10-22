//
//  MatchReminder.swift
//  FootballApp
//
//  İzlənən oyun üçün "oyun başlayır" bildirişinin datası və onu planlaşdıran/saxlayan
//  protokollar. Implementasiyalar Data qatındadır (UserNotifications, UserDefaults).
//

import Foundation

/// Bildirişi yenidən qurmaq üçün oyunun qısa məlumatı (Settings-də bildiriş yenidən açılanda lazımdır).
struct MatchReminder: Codable, Equatable {
    let matchID: Int
    let home: String
    let away: String
    let competition: String
    let kickoff: Date
}

protocol MatchReminderScheduling {
    /// İcazə hələ soruşulmayıbsa soruşur. `true`: bildiriş göstərmək olar.
    func requestAuthorization() async -> Bool
    /// `date` vaxtı bildiriş göstərir. Eyni oyun üçün köhnə bildiriş əvəz olunur.
    func schedule(_ reminder: MatchReminder, at date: Date) async throws
    func cancel(matchID: Int)
    func cancelAll()
}

/// Planlaşdırılmış xatırlatmaların siyahısı.
protocol MatchReminderStoring: AnyObject {
    var reminders: [MatchReminder] { get }
    func save(_ reminder: MatchReminder)
    func remove(matchID: Int)
    func clear()
}
