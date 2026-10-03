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
    func showMatchDetail(matchID: Int)
    func showLeagueDetail(for league: League)
}

protocol ExploreNavigating: AnyObject {
    
}

protocol StandingNavigating: AnyObject {
    
}

/// Nav bar-ı gizli olan ekranlar (öz header-i var). Qərarı HomeCoordinator verir.
protocol HidesNavigationBar: UIViewController {}
