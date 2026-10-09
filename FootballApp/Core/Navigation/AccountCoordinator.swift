import UIKit

final class AccountCoordinator: NSObject, NavigationCoordinator, ProfileNavigating, EditProfileNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    /// MainTabBarCoordinator-a xəbər verir; sessiyanı silmək və ekranı dəyişmək onun yuxarısının işidir.
    var onLogout: (() -> Void)?

    private let authService: AuthProviding
    private let profileStore: ProfileStoring
    private let activityStore: ActivityStoring
    private let settings: SettingsStoring
    private let matchDetailService: MatchDetailProviding
    private let subscriptions: MatchSubscriptionStoring

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
        matchDetailService: MatchDetailProviding = MockMatchDetailService(),
        subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
        self.navigationController = navigationController
        self.authService = authService
        self.profileStore = profileStore
        self.activityStore = activityStore
        self.settings = settings
        self.matchDetailService = matchDetailService
        self.subscriptions = subscriptions
        super.init()
        navigationController.delegate = self
    }

    func start() {
        let vc = ProfileViewController(profile: profile, activityStore: activityStore, settings: settings)
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
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func logout() {
           // Profil, Activity və bildiriş seçimləri istifadəçiyə aiddir; Settings cihaza aid olduğu üçün qalır.
           profileStore.clear()
           activityStore.clear()
           subscriptions.clear()
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
        // Bu tab-da bütün ekranların öz header-i var, nav bar həmişə gizlidir.
        // Bar gizli olanda UIKit swipe-back jestini söndürür; burada qaytarırıq.
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AccountCoordinator: UIGestureRecognizerDelegate {
    /// Root ekranda jest başlamasın (yoxsa UI donur).
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}
