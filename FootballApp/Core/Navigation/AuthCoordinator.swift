import UIKit

final class AuthCoordinator: NSObject, Coordinator, AuthNavigating {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> Void)?
   
    var onCancel: (() -> Void)?

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
            self.present(nav)
        }
    }

    func showSignUp() {
        presentAfterDismissingCurrent { [weak self] in
            guard let self else { return }
            let vc = SignUpController()
            vc.coordinator = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav)
        }
    }

    /// Back düyməsi: auth ləğv olundu.
    func dismissAuth() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }

    func authFinished() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onFinish?()
        }
    }

    // MARK: - Private

    private func present(_ nav: UINavigationController) {
        // Delegate bütün present-lərdə qurulur ki, əl ilə bağlanma həmişə tutulsun.
        nav.presentationController?.delegate = self
        navigationController.present(nav, animated: true)
    }

    private func presentAfterDismissingCurrent(_ present: @escaping () -> Void) {
        if navigationController.presentedViewController != nil {
            // Proqramlı dismiss presentationControllerDidDismiss-i çağırmır,
            // ona görə sign in <-> sign up keçidi yalançı "cancel" yaratmır.
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

// MARK: - UIAdaptivePresentationControllerDelegate

extension AuthCoordinator: UIAdaptivePresentationControllerDelegate {
    /// Yalnız istifadəçi sheet-i özü (swipe ilə) bağlayanda çağırılır.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onCancel?()
    }
}
