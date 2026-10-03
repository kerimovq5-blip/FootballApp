//
//  ExploreCoordinator.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import UIKit

final class ExploreCoordinator: NavigationCoordinator, ExploreNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ExploreViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
}
