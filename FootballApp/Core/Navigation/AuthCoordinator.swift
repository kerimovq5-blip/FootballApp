import UIKit

final class AuthCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let halfDetentID = UISheetPresentationController.Detent.Identifier("half")

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        start(showSignUp: false)
    }

    func start(showSignUp: Bool) {
        presentSignIn()
    }

    private func presentSignIn() {
        let vc = SignInController()

        vc.onSignInTapped = { [weak self] in
            // TODO: AuthService ilə giriş yoxlanışı
            self?.navigationController.dismiss(animated: true)
        }
        vc.onSignUpTapped = { [weak self] in
            vc.dismiss(animated: true) {
                self?.start(showSignUp: true)
            }
        }
        vc.onForgotPasswordTapped = { [weak self] in
            // TODO: Forgot password ekranı
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: halfDetentID) { context in
                    context.maximumDetentValue * 0.65
                },
                .large()
            ]
            sheet.selectedDetentIdentifier = halfDetentID
            sheet.preferredCornerRadius = 30
            sheet.prefersGrabberVisible = true
        }

        navigationController.present(vc, animated: true)
    }
}
