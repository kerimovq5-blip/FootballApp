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

    private let standingService: StandingProviding

    init(navigationController: UINavigationController = UINavigationController(),
         standingService: StandingProviding = MockStandingService()) {
        self.navigationController = navigationController
        self.standingService = standingService
    }

    func start() {
        let viewModel = StandingViewModel(service: standingService)
        let vc = StandingViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([vc], animated: false)
    }
} 
