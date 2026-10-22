//
//  ExploreViewModel.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

final class ExploreViewModel {

    /// Data və ya seçilmiş tab dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((String) -> Void)?

    private(set) var selectedTab: ExploreTab = .leagues

    private let service: ExploreProviding
    private var content: ExploreContent?

    init(service: ExploreProviding) {
        self.service = service
    }

    // MARK: - Output

    var leagues: [League] {
        content?.leagues ?? []
    }

    /// Seçilmiş sıralama tab-ının sətirləri; Leagues tab-ında boşdur.
    var rankings: [RankingEntry] {
        switch selectedTab {
        case .leagues: return []
        case .uefaClubs: return content?.uefaClubs ?? []
        case .fifaNations: return content?.fifaNations ?? []
        case .uefaCountries: return content?.uefaCountries ?? []
        }
    }

    var numberOfRows: Int {
        selectedTab == .leagues ? leagues.count : rankings.count
    }

    // MARK: - Input

    func load() {
        service.fetchExplore { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                self.content = content
                self.onChange?()
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
    }

    func select(_ tab: ExploreTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        onChange?()
    }
}
