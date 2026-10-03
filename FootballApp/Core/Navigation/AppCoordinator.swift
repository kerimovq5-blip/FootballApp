import UIKit

final class AppCoordinator: Coordinator, OnboardingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let sessionStore: SessionStoring

    init(navigationController: UINavigationController,
         sessionStore: SessionStoring = UserDefaultsSessionStore()) {
        self.navigationController = navigationController
        self.sessionStore = sessionStore
    }

    func start() {
        if sessionStore.token != nil {
            showMain(animated: false)
        } else {
            showStart(animated: false)
        }
    }

    func showSignIn() {
        startAuth(showSignUp: false)
    }

    func showSignUp() {
        startAuth(showSignUp: true)
    }

    // MARK: - Flows

    private func showStart(animated: Bool) {
        let vc = StartController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: animated)
    }

    private func startAuth(showSignUp: Bool) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(authCoordinator)

        authCoordinator.onFinish = { [weak self, weak authCoordinator] in
            self?.remove(authCoordinator)
            self?.didAuthenticate()
        }
        authCoordinator.onCancel = { [weak self, weak authCoordinator] in
            self?.remove(authCoordinator)
        }
        authCoordinator.start(showSignUp: showSignUp)
    }

    private func didAuthenticate() {
        // TODO: real auth gələndə API-dən gələn token burada saxlanılacaq.
        sessionStore.save(token: "mock-token")
        showMain(animated: true)
    }

    private func showMain(animated: Bool) {
        let tabBarController = MainTabbarController()
        let tabBarCoordinator = MainTabBarCoordinator(tabBarController: tabBarController)

        tabBarCoordinator.onLogout = { [weak self, weak tabBarCoordinator] in
            self?.remove(tabBarCoordinator)
            self?.sessionStore.clear()
            self?.showStart(animated: true)
        }

        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        navigationController.setViewControllers([tabBarController], animated: animated)
    }

    private func remove(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}
