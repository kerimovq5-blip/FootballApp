

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
//        
//        let title = showSignUp ? "Sign Up" : "Sign In"
        let vc = SignInController()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { context in
                    context.maximumDetentValue * 0.65
                },
                .large()
            ]

            sheet.selectedDetentIdentifier = .init("custom")
            sheet.preferredCornerRadius = 30
            sheet.prefersGrabberVisible = true
        }
       
        navigationController.present(vc, animated: true)
    }
}
