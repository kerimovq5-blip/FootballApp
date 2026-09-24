//
//  AppColor.swift
//  SilentMoon
//
//  Created by Kerimov Qehreman on 25.06.26.
//

//



import UIKit

enum ImagePosition {
    case leading
    case trailing
}

enum AssetColors : String{
    
    case background = "Background"
    case textPrimary = "TextPrimary"
    case textSecondary  = "TextSecondary"
    case accent = "AccentColor"
    case buttonTitlecolor = "ButtonTitleColor"
    
   
    
    var color : UIColor {
        return UIColor(named: self.rawValue) ?? .clear
        
    }
    
}

extension UIColor  {
    func assetColor( _ colorName : AssetColors) -> UIColor {
        return colorName.color
    }
    
}


extension UIColor {
    static var background: UIColor { AssetColors.background.color }
    static var textPrimary: UIColor { AssetColors.textPrimary.color }
    static var textSecondary: UIColor { AssetColors.textSecondary.color }
    static var accent: UIColor { AssetColors.accent.color }
    static var buttonTitlecolor: UIColor { AssetColors.buttonTitlecolor.color }
    
    
}

enum AppFonts {
    case title
    case titleBold
    case titleRegular
    case body
    case regularBody
    case litletitle
    case semiBold
    case mediumTitle
    var font: UIFont {
        switch self {
        case .title:
            return UIFont.systemFont(ofSize: 30, weight: .bold)
        case .titleBold:
            return UIFont.systemFont(ofSize: 24, weight: .bold)
        case .titleRegular:
            return UIFont.systemFont(ofSize: 28, weight: .regular)
        case .body:
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        case .regularBody:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .litletitle:
            return UIFont.systemFont(ofSize: 12, weight: .regular)
        case .semiBold:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .mediumTitle :
            return UIFont.systemFont(ofSize: 13, weight: .medium)
        }
    }
}
enum AppRadius{
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
            case .buttonRadiusLarge , .sessionPlayButtonRadius:
                return 25
            }
        }
    }
