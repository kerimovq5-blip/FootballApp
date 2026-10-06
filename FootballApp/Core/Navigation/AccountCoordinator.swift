//
//  AccountCoordinator.swift
//  FootballApp
//

import UIKit

final class AccountCoordinator: NavigationCoordinator, ProfileNavigating, EditProfileNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    /// MainTabBarCoordinator-a xəbər verir; sessiyanı silmək və ekranı dəyişmək onun yuxarısının işidir.
    var onLogout: (() -> Void)?

    /// Real user datası gələnə qədər müvəqqəti.
    private var profile = ProfileInfo(name: "Servan Eyvazov",
                                      email: "servan.eyvazov@gmail.com",
                                      bio: "#YNWK till the end 🔥",
                                      avatar: nil)

    private weak var profileViewController: ProfileViewController?

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileViewController(profile: profile)
        vc.coordinator = self
        profileViewController = vc
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - ProfileNavigating

    func showEditProfile() {
        let vc = EditProfileViewController(profile: profile)
        vc.coordinator = self
        let nav = UINavigationController(rootViewController: vc)
        navigationController.present(nav, animated: true)
    }

    func logout() {
        onLogout?()
    }

    // MARK: - EditProfileNavigating

    func didSaveProfile(_ profile: ProfileInfo) {
        self.profile = profile
        profileViewController?.update(profile)
        navigationController.dismiss(animated: true)
    }

    func cancelEditProfile() {
        navigationController.dismiss(animated: true)
    }
}
