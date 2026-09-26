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
        if showSignUp {
            presentSignUp()
        } else {
            presentSignIn()
        }
    }

    private func presentSignIn() {
        let vc = SignInController()
        let nav = UINavigationController(rootViewController: vc)

        vc.onSignInTapped = { [weak self] in
            // TODO: AuthService ilə giriş yoxlanışı
            self?.navigationController.dismiss(animated: true)
        }
        vc.onSignUpTapped = { [weak self] in
            self?.navigationController.dismiss(animated: true) {
                self?.presentSignUp()
            }
        }
        vc.onForgotPasswordTapped = { [weak self] in
            // TODO: Forgot password ekranı
        }

        configureSheet(for: nav)
        navigationController.present(nav, animated: true)
    }

    private func presentSignUp() {
        let vc = SignUpController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen

        vc.onSignUpTapped = { [weak self] in
            // TODO: AuthService ilə qeydiyyat
            self?.navigationController.dismiss(animated: true)
        }
        vc.onSignInTapped = { [weak self] in
            self?.navigationController.dismiss(animated: true) {
                self?.presentSignIn()
            }
        }

        navigationController.present(nav, animated: true)
    }

    private func configureSheet(for nav: UINavigationController) {
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
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
    }
}
