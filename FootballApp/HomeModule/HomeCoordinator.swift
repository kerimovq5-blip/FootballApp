//
//  HomeCoordinator.swift
//  FootballApp
//
//  Created by Servan on 27.09.26.
//
import UIKit

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = HomeController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
