//
//  DetailTab.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

enum MatchDetailsTab :  CaseIterable {
    case matchDetail
    case lineUp
    case h2h
    
    var title: String {
        switch self {
        case .matchDetail: return "Match Detail"
        case .lineUp: return "Line Up"
        case .h2h: return "H2H"
        }
    }
}
