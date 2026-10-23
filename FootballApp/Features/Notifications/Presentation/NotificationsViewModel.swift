import Foundation
import UIKit

final class NotificationsViewModel {

    /// Data yenilənəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((UserFacingError) -> Void)?

    /// Yalnız bildirişi açılmış oyunlar, liqalara görə qruplaşdırılmış.
    private(set) var leagues: [League] = []

    private let service: HomeProviding
    private let alerts: MatchAlertsUseCase

    init(service: HomeProviding = AppEnvironment.current.home,
         alerts: MatchAlertsUseCase = AppEnvironment.current.matchAlerts) {
        self.service = service
        self.alerts = alerts
    }

    func load() {
        service.fetchHome { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                let ids = self.alerts.followedMatchIDs
                self.leagues = content.leagues.compactMap { league in
                    let matches = league.matches.filter { ids.contains($0.id) }
                    guard !matches.isEmpty else { return nil }
                    return League(id: league.id, name: league.name, country: league.country,
                                  flag: league.flag, matches: matches)
                }
                self.onChange?()
            case .failure(let error):
                self.onFailed?(UserFacingError(error))
            }
        }
    }

    func match(at indexPath: IndexPath) -> Match? {
        guard leagues.indices.contains(indexPath.section),
              leagues[indexPath.section].matches.indices.contains(indexPath.item) else { return nil }
        return leagues[indexPath.section].matches[indexPath.item]
    }

    /// Oyunu izləməni dayandırır (xatırlatma da silinir) və siyahını yeniləyir.
    func unsubscribe(matchID: Int) {
        alerts.unfollow(matchID: matchID)
        load()
    }
}
