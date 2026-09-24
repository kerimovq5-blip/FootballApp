//
//  AppCoordinator.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 23.09.26.
//

import UIKit

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showOnboarding()
    }

    private func showOnboarding() {
        let vc = ViewController()
        vc.onSignUpTapped = { [weak self] in
            self?.startAuth(showSignUp: true)
        }
        vc.onSignInTapped = { [weak self] in
            self?.startAuth(showSignUp: false)
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func startAuth(showSignUp: Bool) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(authCoordinator)
        authCoordinator.start(showSignUp: showSignUp)
    }
}
