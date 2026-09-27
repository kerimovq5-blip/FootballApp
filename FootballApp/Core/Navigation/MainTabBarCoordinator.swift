//
//  MainTabBarCoordinator.swift
//  FootballApp
//
//  Created by Servan on 27.09.26.
//
import UIKit

final class MainTabBarCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController())
        homeCoordinator.start()
        homeCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        childCoordinators = [homeCoordinator]

        let tabBarController = MainTabbarController()
        tabBarController.viewControllers = childCoordinators.map { $0.navigationController }

        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
