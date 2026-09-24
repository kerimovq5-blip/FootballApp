import CoreGraphics

enum AppLayout {
    case smallSpacing
    case mediumSpacing
    case spacing
    case largeSpacing
    
    
 
    
    var value: CGFloat {
        switch self {
        case .smallSpacing: return 8
        case .mediumSpacing : return 30
        case .spacing: return 20
        case .largeSpacing: return 50
       
        
        }
    }
}

extension AppLayout {
    static let frameHeightMultiplier: CGFloat = 0.55
    static let sectionWidthMultiplier: CGFloat = 0.16
}
