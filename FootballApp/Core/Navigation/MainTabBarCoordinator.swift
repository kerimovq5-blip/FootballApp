


import UIKit

final class MainTabBarCoordinator: Coordinator  {
    var childCoordinators: [Coordinator] = []
    let tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        tabBarController.viewControllers = [
            makeHomeTab(),
            makeExploreTab(),
            makeStandingTab(),
            makeAccountTab()
            
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
            image: UIImage(named: "home"),
            tag: 0
        )
        childCoordinators.append(homeCoordinator)
        return homeCoordinator.navigationController
    }

    private func makeAccountTab() -> UINavigationController {
        //        let accountController = AccountViewController()
        //        let navigation = UINavigationController(rootViewController: accountController)
        //        navigation.tabBarItem = UITabBarItem(
        //            title: "Account",
        //            image: UIImage(named: "Account"),
        //            tag: 3
        //        )
        //        return navigation
        //
        return UINavigationController()
    }
}

extension MainTabBarCoordinator : ExploreNavigating {
    
    private func makeExploreTab() -> UINavigationController {
        let exploreController = ExploreViewController()
        exploreController.coordinator = self
        let navigation = UINavigationController(rootViewController: exploreController)
        navigation.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(named: "Explore"),
            tag: 1
        )
        return navigation
    }
    
}

extension MainTabBarCoordinator : StandingNavigating {
    private func makeStandingTab() -> UINavigationController {
        let standingController = StandingViewController()
        standingController.coordinator = self
        let navigation = UINavigationController(rootViewController: standingController)
        navigation.tabBarItem = UITabBarItem(
            title: "Standing",
            image: UIImage(named: "Standing"),
            tag: 2
        )
        return navigation
    }
    
}
