import UIKit

final class AppCoordinator: Coordinator, OnboardingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let authService: AuthProviding

    init(navigationController: UINavigationController,
         authService: AuthProviding = FirebaseAuthService()) {
        self.navigationController = navigationController
        self.authService = authService
    }

    /// App always launches from the Start screen.
    /// Remember me seçilibsə birbaşa Home, yoxsa Start ekranı.
    func start() {
        if authService.currentUser != nil {
            if RememberMeStore.isEnabled {
                showMain(animated: false)
                return
            }
            // Remember me seçilməyib: köhnə sessiya bağlanır.
            authService.logout { _ in }
        }
        showStart(animated: false)
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
        let authCoordinator = AuthCoordinator(navigationController: navigationController, authService: authService)
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
        // Firebase session is already created by the SignIn/SignUp view model.
        showMain(animated: true)
    }

    private func showMain(animated: Bool) {
        let tabBarController = MainTabbarController()
        let tabBarCoordinator = MainTabBarCoordinator(tabBarController: tabBarController, authService: authService)

        tabBarCoordinator.onLogout = { [weak self, weak tabBarCoordinator] in
            self?.remove(tabBarCoordinator)
            self?.authService.logout { _ in }
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
