import UIKit

final class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let tabBarController: UITabBarController

    var onLogout: (() -> Void)?

    private let authService: AuthProviding

    init(tabBarController: UITabBarController, authService: AuthProviding) {
        self.tabBarController = tabBarController
        self.authService = authService
    }

    func start() {
        tabBarController.viewControllers = [
            makeTab(HomeCoordinator(navigationController: UINavigationController()),
                    title: "Home", image: UIImage(named: "home"), tag: 0),
            makeTab(ExploreCoordinator(),
                    title: "Explore", image: UIImage(named: "Explore"), tag: 1),
            makeTab(StandingCoordinator(),
                    title: "Standing", image: UIImage(named: "Standing"), tag: 2),
            makeTab(makeAccountCoordinator(),
                    title: "Account", image: UIImage(systemName: "person"), tag: 3)
        ]
    }

    /// AccountCoordinator çıxış edəndə bunu çağırır.
    func logout() {
        onLogout?()
    }

    /// Hər tab eyni qaydada qurulur: coordinator start olur, tab item qoyulur, saxlanılır.
    private func makeTab(_ coordinator: NavigationCoordinator,
                         title: String,
                         image: UIImage?,
                         tag: Int) -> UINavigationController {
        coordinator.start()
        coordinator.navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            tag: tag
        )
        childCoordinators.append(coordinator)
        return coordinator.navigationController
    }

    private func makeAccountCoordinator() -> AccountCoordinator {
        let coordinator = AccountCoordinator(authService: authService)
        coordinator.onLogout = { [weak self] in
            self?.logout()
        }
        return coordinator
    }
}
