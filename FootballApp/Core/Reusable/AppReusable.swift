//
//  AppColor.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 25.06.26.
//

import UIKit

enum ImagePosition {
    case leading
    case trailing
}

enum AssetColors: String {

    case background = "Background"
    case textPrimary = "TextPrimary"
    case textSecondary = "TextSecondary"
    case accent = "AccentColor"
    case buttonTitlecolor , titleColor = "ButtonTitleColor"
    case labelColor = "LabelColor"
    case placeholderColor = "placeholdercolor"
    case backgroundColor2 = "backgroundColor2"

    var color: UIColor {
        return UIColor(named: self.rawValue) ?? .clear
    }
}



enum AppRadius {
    case buttonRadius
    case buttonRadiusSmall
    case buttonRadiusMedium
    case buttonRadiusLarge
    case sessionPlayButtonRadius

    var radius: CGFloat {
        switch self {
        case .buttonRadius:
            return 30
        case .buttonRadiusSmall:
            return 16
        case .buttonRadiusMedium:
            return 20
        case .buttonRadiusLarge, .sessionPlayButtonRadius:
            return 25
        }
    }
}
