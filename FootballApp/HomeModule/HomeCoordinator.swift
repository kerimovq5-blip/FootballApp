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
        
        vc.onSearchTapped = { [weak self] in
            self?.showSearch()
        }
        vc.onNotificationTapped = { [weak self] in
            self?.showNotifications( )
        }
        
        navigationController.setViewControllers([vc], animated: false)
        
        
    }
    private func showSearch() {
        let vc = SearchController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    private func showNotifications() {
        let vc = NotificationsController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
