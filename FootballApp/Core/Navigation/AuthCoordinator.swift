

import UIKit


final class AuthCoordinator: Coordinator {
    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        start(showSignUp: false)
    }

    func start(showSignUp: Bool) {
        
        let title = showSignUp ? "Sign Up" : "Sign In"
        let vc = UIViewController()
        vc.title = title
        vc.view.backgroundColor = AssetColors.background.color
        navigationController.pushViewController(vc, animated: true)
    }
}
