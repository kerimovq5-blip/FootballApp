import UIKit

final class AuthCoordinator: Coordinator, AuthNavigating {
    

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    private let halfDetentID = UISheetPresentationController.Detent.Identifier("half")

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(showSignUp: Bool) {
        showSignUp ? self.showSignUp() : self.showSignIn()
    }
    func start() {
            start(showSignUp: false)
        }

    func showSignIn() {
        presentAfterDismissingCurrent { [weak self] in
            guard let self else { return }
            let vc = SignInController()
            vc.coordinator = self
            let nav = UINavigationController(rootViewController: vc)
            self.configureSheet(for: nav)
            self.navigationController.present(nav, animated: true)
        }
    }

    func showSignUp() {
        presentAfterDismissingCurrent { [weak self] in
            guard let self else { return }
            let vc = SignUpController()
            vc.coordinator = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController.present(nav, animated: true)
        }
    }

    func dismissAuth() {
        navigationController.dismiss(animated: true)
    }

    func authFinished() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onFinish?()
        }
    }

    private func presentAfterDismissingCurrent(_ present: @escaping () -> Void) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true, completion: present)
        } else {
            present()
        }
    }

    private func configureSheet(for nav: UINavigationController) {
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: halfDetentID) { context in
                    context.maximumDetentValue * 0.6
                },
                .large()
            ]
            sheet.selectedDetentIdentifier = halfDetentID
            sheet.preferredCornerRadius = 30
            sheet.prefersGrabberVisible = true
        }
    }
}
