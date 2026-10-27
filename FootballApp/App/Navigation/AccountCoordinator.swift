import UIKit

final class AccountCoordinator: NSObject, NavigationCoordinator, ProfileNavigating, EditProfileNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    var onLogout: (() -> Void)?

    private let authService: AuthProviding
    private let profileStore: ProfileStoring
    private let activityStore: ActivityStoring
    private let settings: SettingsStoring
    private let matchDetailService: MatchDetailProviding
    private let alerts: MatchAlertsUseCase

    /// Saved profile if there is one; otherwise built from the Firebase user.
    private lazy var profile: ProfileInfo = {
        let user = authService.currentUser
        let email = user?.email ?? ""
        let fallbackName = email.components(separatedBy: "@").first ?? ""
        let name = (user?.name).flatMap { $0.isEmpty ? nil : $0 } ?? fallbackName
        return profileStore.load(email: email)
            ?? ProfileInfo(name: name, email: email, bio: "", avatar: nil, phone: "", address: "")
    }()

    private weak var profileViewController: ProfileViewController?

    init(
        authService: AuthProviding,
        navigationController: UINavigationController = UINavigationController(),
        profileStore: ProfileStoring = UserDefaultsProfileStore(),
        activityStore: ActivityStoring = UserDefaultsActivityStore.shared,
        settings: SettingsStoring = UserDefaultsSettingsStore(),
        matchDetailService: MatchDetailProviding = AppEnvironment.current.matchDetail,
        alerts: MatchAlertsUseCase = AppEnvironment.current.matchAlerts) {
        self.navigationController = navigationController
        self.authService = authService
        self.profileStore = profileStore
        self.activityStore = activityStore
        self.settings = settings
        self.matchDetailService = matchDetailService
        self.alerts = alerts
        super.init()
        navigationController.delegate = self
    }

    func start() {
        let vc = ProfileViewController(profile: profile, activityStore: activityStore,
                                       settings: settings, alerts: alerts)
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

    func showMatchDetail(matchID: Int) {
        let viewModel = MatchDetailViewModel(matchID: matchID, service: matchDetailService)
        let vc = MatchDetailController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func logout() {
          
          
           onLogout?()
       }
    // MARK: - EditProfileNavigating

    func didSaveProfile(_ profile: ProfileInfo) {
        self.profile = profile
        profileStore.save(profile)
        profileViewController?.update(profile)
        navigationController.dismiss(animated: true)
    }

    func cancelEditProfile() {
        navigationController.dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension AccountCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AccountCoordinator: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}
