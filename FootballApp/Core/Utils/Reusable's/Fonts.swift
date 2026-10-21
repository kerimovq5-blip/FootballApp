//
//  Fonts.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 15.10.26.
//

import UIKit

extension UIFont {
     
    @nonobjc class var title: UIFont {
            return UIFont.systemFont(ofSize: 30, weight: .bold)
        }

        @nonobjc class var titleBold: UIFont {
            return UIFont.systemFont(ofSize: 24, weight: .bold)
        }

        @nonobjc class var titleRegular: UIFont {
            return UIFont.systemFont(ofSize: 28, weight: .regular)
        }

        @nonobjc class var semiBold: UIFont {
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        }

        @nonobjc class var mediumTitle: UIFont {
            return UIFont.systemFont(ofSize: 13, weight: .medium)
        }

        // MARK: Body
        // ----------------------------------------
        @nonobjc class var body: UIFont {
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        }

        @nonobjc class var regularBody: UIFont {
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        }

        @nonobjc class var litletitle: UIFont {
            return UIFont.systemFont(ofSize: 12, weight: .regular)
        }
    }
