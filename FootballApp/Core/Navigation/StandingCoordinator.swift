//
//  StandingCoordinator.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import UIKit

final class StandingCoordinator: NavigationCoordinator, StandingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = StandingViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
}
