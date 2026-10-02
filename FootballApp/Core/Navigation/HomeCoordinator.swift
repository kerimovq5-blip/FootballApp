import UIKit

final class HomeCoordinator: Coordinator, HomeNavigating {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = HomeController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showSearch() {
        let vc = SearchController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showNotifications() {
        let vc = NotificationsController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showLeagueDetail(for league: League) {
        let vc = LeagueDetailController(league: league)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showMatchDetail(for match: Match) {
        let data = MatchDetailData(
            competitionName: "UEFA Champions League",
            homeName: match.home,
            awayName: match.away,
            homeCrest: nil,
            awayCrest: nil,
            score: "\(match.homeScore ?? 0) - \(match.awayScore ?? 0)",
            minuteOrStatus: "90.15",
            stats: [
                .init(title: "Shooting", homeValue: "8", awayValue: "12"),
                .init(title: "Attacks", homeValue: "22", awayValue: "29"),
                .init(title: "Possesion", homeValue: "42", awayValue: "58"),
                .init(title: "Cards", homeValue: "3", awayValue: "5"),
                .init(title: "Corners", homeValue: "8", awayValue: "7")
            ],
            formationName: "4-2-3-1",
            formation: [
                [.init(number: 1, name: "Leno")],
                [.init(number: 3, name: "Tierney"), .init(number: 22, name: "Pablo Mari"), .init(number: 16, name: "Holding"), .init(number: 2, name: "Bellerin")],
                [.init(number: 34, name: "Xhaka"), .init(number: 8, name: "Dani Ceballos")],
                [.init(number: 14, name: "Aubameyang"), .init(number: 9, name: "Lacazette"), .init(number: 7, name: "Saka")]
            ],
            headToHead: HeadToHead(
                homeWins: 4,
                draws: 3,
                awayWins: 3,
                meetings: [
                    .init(date: "12.03.2025", competition: "UCL", homeTeam: match.home, awayTeam: match.away, homeScore: 2, awayScore: 3),
                    .init(date: "05.11.2024", competition: "UCL", homeTeam: match.away, awayTeam: match.home, homeScore: 1, awayScore: 1)
                ]
            )
        )
        let vc = MatchDetailController(data: data)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
