//
//  SearchSection.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


//
//  SearchViewModel.swift
//  FootballApp
//

import Foundation
import UIKit


enum SearchSection {
    case recent
    case leagues
    case matches(leagueIndex: Int)
}

final class SearchViewModel {

    /// Nəticə dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((String) -> Void)?

    private(set) var sections: [SearchSection] = []
    private(set) var recentSearches: [String]
    private(set) var leagueResults: [League] = []
    /// Yalnız axtarışa uyğun oyunlar, liqalara görə qruplaşdırılmış.
    private(set) var matchResults: [League] = []

    private let service: SearchProviding
    private let recents: RecentSearchStoring
    private var content: SearchContent?
    private var query = ""

    init(service: SearchProviding,
         recents: RecentSearchStoring = UserDefaultsRecentSearchStore.shared) {
        self.service = service
        self.recents = recents
        self.recentSearches = recents.items
    }

    // MARK: - Output

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Göstəriləcək nəticə yoxdursa ekranın ortasındakı mesaj; əks halda nil.
    var placeholderMessage: String? {
        guard content != nil, sections.isEmpty else { return nil }
        if trimmedQuery.isEmpty {
            return "Search for teams and leagues.\nYour recent searches will appear here."
        }
        return "No results for “\(trimmedQuery)”.\nCheck the spelling or try another team or league."
    }

    func numberOfItems(in section: Int) -> Int {
        switch sections[section] {
        case .recent: return recentSearches.count
        case .leagues: return leagueResults.count
        case .matches(let index): return matchResults[index].matches.count
        }
    }

    func league(forMatchSection section: Int) -> League? {
        guard case .matches(let index) = sections[section] else { return nil }
        return matchResults[index]
    }

    func match(at indexPath: IndexPath) -> Match? {
        league(forMatchSection: indexPath.section)?.matches[indexPath.item]
    }

    // MARK: - Input

    func load() {
        service.fetchSearchContent { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                self.content = content
                self.refresh()
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
    }

    func updateQuery(_ text: String) {
        query = text
        refresh()
    }

    /// Axtarış faydalı olubsa (nəticə var) son axtarışlara yazılır.
    func commitQuery() {
        guard !trimmedQuery.isEmpty, !leagueResults.isEmpty || !matchResults.isEmpty else { return }
        recents.add(trimmedQuery)
        recentSearches = recents.items
    }

    func clearRecents() {
        recents.clear()
        recentSearches = []
        refresh()
    }

    // MARK: - Private

    private func refresh() {
        let text = trimmedQuery

        if text.isEmpty {
            leagueResults = []
            matchResults = []
            sections = recentSearches.isEmpty ? [] : [.recent]
        } else {
            let source = content ?? SearchContent(leagues: [], matchLeagues: [])

            leagueResults = source.leagues.filter {
                matches($0.name, text) || matches($0.country, text)
            }
            matchResults = source.matchLeagues.compactMap { league in
                let found = league.matches.filter { matches($0.home, text) || matches($0.away, text) }
                guard !found.isEmpty else { return nil }
                return League(id: league.id, name: league.name, country: league.country,
                              flag: league.flag, matches: found)
            }

            var result: [SearchSection] = []
            if !leagueResults.isEmpty { result.append(.leagues) }
            result += matchResults.indices.map { SearchSection.matches(leagueIndex: $0) }
            sections = result
        }
        onChange?()
    }

    /// Hərf böyüklüyü və işarələr (ü, ş, ö...) nəzərə alınmır.
    private func matches(_ text: String, _ query: String) -> Bool {
        text.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
