//
//  Navigating's.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 02.10.26.
//

import UIKit

protocol OnboardingNavigating: AnyObject {
    func showSignIn()
    func showSignUp()
}

protocol AuthNavigating: AnyObject {
    func showSignIn()
    func showSignUp()
    func dismissAuth()
    func authFinished()
}

protocol HomeNavigating: AnyObject {
    func showSearch()
    func showNotifications()
    func showMatchDetail(for match: Match)
    func showLeagueDetail(for league: League)
}

protocol ExploreNavigating: AnyObject {
    
}

protocol StandingNavigating: AnyObject {
    
}
