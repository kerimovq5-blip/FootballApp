import Foundation
import UIKit
final class NotificationsViewModel {

    /// Data yenilənəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((String) -> Void)?

    /// Yalnız bildirişi açılmış oyunlar, liqalara görə qruplaşdırılmış.
    private(set) var leagues: [League] = []

    private let service: HomeProviding
    private let subscriptions: MatchSubscriptionStoring

    init(service: HomeProviding = MockHomeService(),
         subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
        self.service = service
        self.subscriptions = subscriptions
    }

    func load() {
        service.fetchHome { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                let ids = self.subscriptions.subscribedMatchIDs
                self.leagues = content.leagues.compactMap { league in
                    let matches = league.matches.filter { ids.contains($0.id) }
                    guard !matches.isEmpty else { return nil }
                    return League(id: league.id, name: league.name, country: league.country,
                                  flag: league.flag, matches: matches)
                }
                self.onChange?()
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
    }

    func match(at indexPath: IndexPath) -> Match? {
        guard leagues.indices.contains(indexPath.section),
              leagues[indexPath.section].matches.indices.contains(indexPath.item) else { return nil }
        return leagues[indexPath.section].matches[indexPath.item]
    }

    /// Oyunun bildirişini söndürür və siyahını yeniləyir.
    func unsubscribe(matchID: Int) {
        if subscriptions.isSubscribed(matchID) {
            subscriptions.toggle(matchID)
        }
        load()
    }
}
