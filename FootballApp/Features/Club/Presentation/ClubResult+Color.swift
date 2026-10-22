//
//  ClubResult+Color.swift
//  FootballApp
//

import UIKit

extension ClubResult {

    /// Forma dairəsinin rəngi (W yaşıl, D boz, L qırmızı).
    var color: UIColor {
        switch self {
        case .win: return .systemGreen
        case .draw: return UIColor.white.withAlphaComponent(0.35)
        case .loss: return .systemRed
        }
    }
}
