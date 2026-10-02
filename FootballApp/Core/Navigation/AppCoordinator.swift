import UIKit

final class AppCoordinator: Coordinator, OnboardingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = StartController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showSignIn() {
        startAuth(showSignUp: false)
    }

    func showSignUp() {
        startAuth(showSignUp: true)
    }

    private func startAuth(showSignUp: Bool) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(authCoordinator)
        authCoordinator.onFinish = { [weak self, weak authCoordinator] in
            self?.childCoordinators.removeAll { $0 === authCoordinator }
            self?.showMain()
        }
        authCoordinator.start(showSignUp: showSignUp)
    }

    private func showMain() {
        let tabBarController = MainTabbarController()
        let tabBarCoordinator = MainTabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
