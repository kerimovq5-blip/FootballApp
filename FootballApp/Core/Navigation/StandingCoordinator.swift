//
//  StandingCoordinator.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import UIKit

final class StandingCoordinator: NSObject, NavigationCoordinator, StandingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let standingService: StandingProviding

    init(navigationController: UINavigationController = UINavigationController(),
         standingService: StandingProviding = AppEnvironment.current.standing) {
        self.navigationController = navigationController
        self.standingService = standingService
        super.init()
        navigationController.delegate = self
    }

    func start() {
        let viewModel = StandingViewModel(service: standingService)
        let vc = StandingViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
}

// MARK: - UINavigationControllerDelegate

extension StandingCoordinator: UINavigationControllerDelegate {
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

extension StandingCoordinator: UIGestureRecognizerDelegate {
    /// Root ekranda jest başlamasın (yoxsa UI donur).
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}
