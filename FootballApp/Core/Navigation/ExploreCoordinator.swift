//
//  ExploreCoordinator.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import UIKit

final class ExploreCoordinator: NSObject, NavigationCoordinator, ExploreNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let exploreService: ExploreProviding

    init(navigationController: UINavigationController = UINavigationController(),
         exploreService: ExploreProviding = MockExploreService()) {
        self.navigationController = navigationController
        self.exploreService = exploreService
        super.init()
        navigationController.delegate = self
    }

    func start() {
        let vc = ExploreViewController(viewModel: ExploreViewModel(service: exploreService))
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showLeagueDetail(for league: League) {
        let vc = LeagueDetailController(league: league)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension ExploreCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let hidesBar = viewController is HidesNavigationBar
        navigationController.setNavigationBarHidden(hidesBar, animated: animated)

        // Bar gizli olanda UIKit swipe-back jestini söndürür; burada qaytarırıq.
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ExploreCoordinator: UIGestureRecognizerDelegate {
    /// Root ekranda jest başlamasın (yoxsa UI donur).
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}
