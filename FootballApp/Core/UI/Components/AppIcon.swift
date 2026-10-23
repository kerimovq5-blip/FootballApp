//
//  AppIcon.swift
//  FootballApp
//
//  Tətbiqdəki bütün ikonlar SF Symbols-dur: istənilən ekranda kəskin görünür,
//  tintColor ilə rənglənir və Dark Mode-a uyğunlaşır. Yeni ikon lazım olanda
//  PNG əlavə etmək yerinə buraya bir sətir yazılır.
//

import UIKit

enum AppIcon: String {

    // Tab bar
    case home = "house"
    case homeSelected = "house.fill"
    case explore = "safari"
    case exploreSelected = "safari.fill"
    case standing = "chart.bar"
    case standingSelected = "chart.bar.fill"
    case account = "person"
    case accountSelected = "person.fill"

    // Başlıq düymələri
    case notifications = "bell"
    case search = "magnifyingglass"

    // Form sahələri
    case email = "envelope"
    case password = "lock"
    case user = "person.crop.circle"
    case showPassword = "eye"
    case hidePassword = "eye.slash"

    // Placeholder-lər
    case league = "trophy"

    /// `pointSize` ikonun ölçüsüdür (şrift ölçüsü kimi), `weight` xəttin qalınlığı.
    func image(pointSize: CGFloat = 17, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        UIImage(systemName: rawValue,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight))
    }
}
