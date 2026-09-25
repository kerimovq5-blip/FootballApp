import CoreGraphics

enum AppLayout {
    case smallSpacing
    case spacing
    case mediumSpacing
    case sectionSpacing
    case topSpacing
    case largeSpacing
    case largeTopSpacing
    case screenPadding

    var value: CGFloat {
        switch self {
        case .smallSpacing: return 8
        case .spacing: return 20
        case .mediumSpacing: return 30
        case .sectionSpacing: return 36
        case .topSpacing: return 40
        case .largeSpacing: return 50
        case .largeTopSpacing: return 70
        case .screenPadding: return 24
        }
    }
}

extension AppLayout {
    static let frameHeightMultiplier: CGFloat = 0.55
    static let sectionWidthMultiplier: CGFloat = 0.16
}
