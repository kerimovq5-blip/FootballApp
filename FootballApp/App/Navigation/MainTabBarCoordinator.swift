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
                    title: "Home", icon: .home, selectedIcon: .homeSelected, tag: 0),
            makeTab(ExploreCoordinator(),
                    title: "Explore", icon: .explore, selectedIcon: .exploreSelected, tag: 1),
            makeTab(StandingCoordinator(),
                    title: "Standing", icon: .standing, selectedIcon: .standingSelected, tag: 2),
            makeTab(makeAccountCoordinator(),
                    title: "Account", icon: .account, selectedIcon: .accountSelected, tag: 3)
        ]
    }

    /// Home tab-ına keçib oyunun səhifəsini açır (məs. bildirişə toxunanda).
    func showMatchDetail(matchID: Int) {
        guard let home = childCoordinators.first(where: { $0 is HomeCoordinator }) as? HomeCoordinator else {
            return
        }
        tabBarController.selectedIndex = 0
        home.navigationController.popToRootViewController(animated: false)
        home.showMatchDetail(matchID: matchID)
    }

    /// AccountCoordinator çıxış edəndə bunu çağırır.
    func logout() {
        onLogout?()
    }

    /// Hər tab eyni qaydada qurulur: coordinator start olur, tab item qoyulur, saxlanılır.
    private func makeTab(_ coordinator: NavigationCoordinator,
                         title: String,
                         icon: AppIcon,
                         selectedIcon: AppIcon,
                         tag: Int) -> UINavigationController {
        coordinator.start()
        let item = UITabBarItem(title: title, image: icon.image(), tag: tag)
        // Seçilmiş tab dolu ikonla göstərilir; rəngi tab bar-ın tintColor-u (AccentColor) verir.
        item.selectedImage = selectedIcon.image()
        coordinator.navigationController.tabBarItem = item
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
