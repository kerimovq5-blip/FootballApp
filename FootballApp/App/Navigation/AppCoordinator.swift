import UIKit

final class AppCoordinator: Coordinator, OnboardingNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let authService: AuthProviding
    private let crashReporter: CrashReporting
    private let sessionCleaner: UserSessionCleaner
    
    init(navigationController: UINavigationController,
         authService: AuthProviding = FirebaseAuthService(),
         crashReporter: CrashReporting = FirebaseCrashReporter.shared,
         sessionCleaner: UserSessionCleaner = UserSessionCleaner()) {
        self.navigationController = navigationController
        self.authService = authService
        self.crashReporter = crashReporter
        self.sessionCleaner = sessionCleaner
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
        sessionCleaner.prepare(forUserID: authService.currentUser?.uid)

        let tabBarController = MainTabbarController()
        let tabBarCoordinator = MainTabBarCoordinator(tabBarController: tabBarController, authService: authService)

        // Crash hesabatında kimin olduğunu görmək üçün (UID; email göndərilmir).
        crashReporter.setUser(id: authService.currentUser?.uid)

        tabBarCoordinator.onLogout = { [weak self, weak tabBarCoordinator] in
            self?.sessionCleaner.clearUserData()
            self?.remove(tabBarCoordinator)
            NotificationRouter.shared.onOpenMatch = nil
            self?.crashReporter.setUser(id: nil)
            self?.authService.logout { _ in }
            self?.showStart(animated: true)
        }

        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        navigationController.setViewControllers([tabBarController], animated: animated)

        // Xatırlatmaya toxunanda oyun Home tab-ında açılır.
        NotificationRouter.shared.onOpenMatch = { [weak tabBarCoordinator] matchID in
            tabBarCoordinator?.showMatchDetail(matchID: matchID)
        }
    }

    private func remove(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}
