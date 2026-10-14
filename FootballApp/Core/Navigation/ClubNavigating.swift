//
//  ClubNavigating.swift
//  FootballApp
//

import UIKit

/// Klub, oyunçu və oyun detalına keçid. Bütün tab-ların navigation protokolları bunu genişləndirir.
protocol ClubNavigating: AnyObject {
    func showClubDetail(for club: ClubReference)
    func showPlayerDetail(for player: PlayerReference)
    func showMatchDetail(matchID: Int)
}

/// Standart implementasiya: coordinator-un öz navigation controller-inə push edir.
/// Home və Account öz showMatchDetail-lərini saxlayır (onlara servis inject olunur), qalanlar bunu işlədir.
/// Servislər `AppEnvironment.current`-dən gəlir.
extension ClubNavigating where Self: NavigationCoordinator {

    func showClubDetail(for club: ClubReference) {
        let viewModel = ClubDetailViewModel(club: club, service: AppEnvironment.current.club)
        let vc = ClubDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showPlayerDetail(for player: PlayerReference) {
        let viewModel = PlayerDetailViewModel(player: player, service: AppEnvironment.current.player)
        let vc = PlayerDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showMatchDetail(matchID: Int) {
        let viewModel = MatchDetailViewModel(matchID: matchID, service: AppEnvironment.current.matchDetail)
        let vc = MatchDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
