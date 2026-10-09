import UIKit

final class HomeCoordinator: NSObject, NavigationCoordinator, HomeNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let homeService: HomeProviding
    private let matchDetailService: MatchDetailProviding

    init(navigationController: UINavigationController,
         homeService: HomeProviding = MockHomeService(),
         matchDetailService: MatchDetailProviding = MockMatchDetailService()) {
        self.navigationController = navigationController
        self.homeService = homeService
        self.matchDetailService = matchDetailService
        super.init()
        navigationController.delegate = self
    }

    func start() {
        let vc = HomeController(viewModel: HomeViewModel(service: homeService))
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showSearch() {
        let vc = SearchController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showNotifications() {
            let vc = NotificationsController(viewModel: NotificationsViewModel(service: homeService))
            vc.coordinator = self
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
        }

    func showLeagueDetail(for league: League) {
        let vc = LeagueDetailController(league: league)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showMatchDetail(matchID: Int) {
        let viewModel = MatchDetailViewModel(matchID: matchID, service: matchDetailService)
        let vc = MatchDetailController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension HomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let hidesBar = viewController is HidesNavigationBar
        navigationController.setNavigationBarHidden(hidesBar, animated: animated)

        // Bar gizli olanda UIKit swipe-back jestini söndürür; burada qaytarırıq.
        // View bu nöqtədə yüklənib, ona görə recognizer artıq mövcuddur.
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate

extension HomeCoordinator: UIGestureRecognizerDelegate {
    /// Root ekranda jest başlamasın (yoxsa UI donur).
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}
