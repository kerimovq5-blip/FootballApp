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
    func showLeagueDetail(for league: League)
}

protocol StandingNavigating: AnyObject {
    
}

protocol ProfileNavigating: AnyObject {
    func showEditProfile()
    func showMatchDetail(matchID: Int)
    func logout()
}

protocol EditProfileNavigating: AnyObject {
    func didSaveProfile(_ profile: ProfileInfo)
    func cancelEditProfile()
}

/// Nav bar-ı gizli olan ekranlar (öz header-i var). Qərarı HomeCoordinator verir.
protocol HidesNavigationBar: UIViewController {}
