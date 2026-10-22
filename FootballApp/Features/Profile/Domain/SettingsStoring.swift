//
//  SettingsStoring.swift
//  FootballApp
//

import Foundation

protocol SettingsStoring: AnyObject {
    /// "Match reminders" açarı: izlənən oyunlar üçün xatırlatma göndərilsin.
    var notificationsEnabled: Bool { get set }
}
