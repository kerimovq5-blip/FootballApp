import UIKit

final class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let tabBarController: UITabBarController

    /// İstifadəçi çıxış edəndə AppCoordinator-a xəbər verir; tab-ları sökmək onun işidir.
    var onLogout: (() -> Void)?

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        tabBarController.viewControllers = [
            makeTab(HomeCoordinator(navigationController: UINavigationController()),
                    title: "Home", imageName: "home", tag: 0),
            makeTab(ExploreCoordinator(),
                    title: "Explore", imageName: "Explore", tag: 1),
            makeTab(StandingCoordinator(),
                    title: "Standing", imageName: "Standing", tag: 2),
            makeAccountTab()
        ]
    }

    /// Account tab-ı hazır olanda onun coordinator-u bunu çağıracaq.
    func logout() {
        onLogout?()
    }

    /// Hər tab eyni qaydada qurulur: coordinator start olur, tab item qoyulur, saxlanılır.
    private func makeTab(_ coordinator: NavigationCoordinator,
                         title: String,
                         imageName: String,
                         tag: Int) -> UINavigationController {
        coordinator.start()
        coordinator.navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName),
            tag: tag
        )
        childCoordinators.append(coordinator)
        return coordinator.navigationController
    }

    private func makeAccountTab() -> UINavigationController {
        // TODO: AccountViewController hazır olanda AccountCoordinator ilə makeTab(...) istifadə et.
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "Account",
            image: UIImage(systemName: "person"),
            tag: 3
        )
        return navigationController
    }
}
