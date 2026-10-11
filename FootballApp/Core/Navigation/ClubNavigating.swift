//
//  ClubNavigating.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubNavigating.swift
//  FootballApp
//

import UIKit

/// Klub səhifəsinə və oyun detalına keçid. Bütün tab-ların navigation protokolları bunu genişləndirir.
protocol ClubNavigating: AnyObject {
    func showClubDetail(for club: ClubReference)
    func showMatchDetail(matchID: Int)
}

/// Standart implementasiya: coordinator-un öz navigation controller-inə push edir.
/// Home və Account öz showMatchDetail-lərini saxlayır (onların service-ləri var), qalanlar bunu işlədir.
/// Real API gələndə servislər yalnız burada dəyişəcək.
extension ClubNavigating where Self: NavigationCoordinator {

    func showClubDetail(for club: ClubReference) {
        let viewModel = ClubDetailViewModel(club: club, service: MockClubService())
        let vc = ClubDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showMatchDetail(matchID: Int) {
        let viewModel = MatchDetailViewModel(matchID: matchID, service: MockMatchDetailService())
        let vc = MatchDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}