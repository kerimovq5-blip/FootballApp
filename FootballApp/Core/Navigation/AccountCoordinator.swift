import UIKit

final class AccountCoordinator: NSObject, NavigationCoordinator, ProfileNavigating, EditProfileNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    /// MainTabBarCoordinator-a xəbər verir; sessiyanı silmək və ekranı dəyişmək onun yuxarısının işidir.
    var onLogout: (() -> Void)?

    private let profileStore: ProfileStoring
    private let activityStore: ActivityStoring
    private let settings: SettingsStoring
    private let matchDetailService: MatchDetailProviding
    private let subscriptions: MatchSubscriptionStoring

    /// Real user datası gələnə qədər başlanğıc dəyərlər.
    private static let defaultProfile = ProfileInfo(
        name: "Servan Eyvazov",
        email: "servan.eyvazov@gmail.com",
        bio: "#YNWK till the end 🔥",
        avatar: nil,
        phone: "+99450555555",
        address: "Baku , Azerbaijan"
    )

    /// Əvvəl saxlanmış profil varsa o, yoxdursa başlanğıc dəyərlər.
    private lazy var profile: ProfileInfo = profileStore.load(email: AccountCoordinator.defaultProfile.email)
        ?? AccountCoordinator.defaultProfile

    private weak var profileViewController: ProfileViewController?

    init(
        navigationController: UINavigationController = UINavigationController(),
        profileStore: ProfileStoring = UserDefaultsProfileStore(),
        activityStore: ActivityStoring = UserDefaultsActivityStore.shared,
        settings: SettingsStoring = UserDefaultsSettingsStore(),
        matchDetailService: MatchDetailProviding = MockMatchDetailService(),
        subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
        self.navigationController = navigationController
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
