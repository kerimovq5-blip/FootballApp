import UIKit

final class MainTabBarCoordinator: Coordinator, ExploreNavigating , StandingNavigating {
    var childCoordinators: [Coordinator] = []
    let tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        tabBarController.viewControllers = [
            makeHomeTab(),
            makeExploreTab(),
            makeStandingTab()
            
        ]
    }

    private var activeNavigationController: UINavigationController? {
        tabBarController.selectedViewController as? UINavigationController
    }

    private func makeHomeTab() -> UINavigationController {
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController())
        homeCoordinator.start()
        homeCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        childCoordinators.append(homeCoordinator)
        return homeCoordinator.navigationController
    }

    private func makeExploreTab() -> UINavigationController {
        let exploreController = ExploreViewController()
        exploreController.coordinator = self
        let navigation = UINavigationController(rootViewController: exploreController)
        navigation.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(named: "Explore"),
            selectedImage: UIImage(systemName: "safari.fill")
        )
        return navigation
    }
    
    private func makeStandingTab() -> UINavigationController {
        let standingController = StandingViewController()
        standingController.coordinator = self
        let navigation = UINavigationController(rootViewController: standingController)
        navigation.tabBarItem = UITabBarItem(
            title: "Standing",
            image: UIImage(named: "Standing"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        return navigation
    }
}
