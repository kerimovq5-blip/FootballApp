//
//  SearchViewModel.swift
//  FootballApp
//

import Foundation

enum SearchScope: CaseIterable {
    case all, teams, players

    var title: String {
        switch self {
        case .all: return "All"
        case .teams: return "Teams"
        case .players: return "Players"
        }
    }
}

enum SearchSection {
    case recent
    case leagues
    case clubs
    case players
    case matches(leagueIndex: Int)
}

final class SearchViewModel {

    /// Nəticə dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((UserFacingError) -> Void)?

    private(set) var scope: SearchScope = .all
    private(set) var sections: [SearchSection] = []
    private(set) var recentSearches: [String]
    private(set) var leagueResults: [League] = []
    private(set) var clubResults: [ClubReference] = []
    private(set) var playerResults: [PlayerSearchResult] = []
    /// Yalnız axtarışa uyğun oyunlar, liqalara görə qruplaşdırılmış.
    private(set) var matchResults: [League] = []

    private let service: SearchProviding
    private let recents: RecentSearchStoring
    private var content: SearchContent?
    private var query = ""

    /// API-dən gələn komanda və oyunçular, təmizlənmiş sorğuya görə (eyni sorğu təkrar göndərilmir).
    private var remoteCache: [String: RemoteSearchResults] = [:]
    /// Hazırkı sorğunun API nəticəsi; sorğu qısadırsa və ya hələ gəlməyibsə nil.
    private var remote: RemoteSearchResults?
    /// API axtarışı alınmadısa (internet, limit) boş nəticə əvəzinə bu göstərilir.
    private var remoteError: UserFacingError?
    /// Gedən API axtarışı. Yeni sorğu köhnəsini ləğv edir; testlər bitməsini gözləyir.
    private(set) var remoteTask: Task<Void, Never>?

    /// All tabında hər kateqoriyadan neçə nəticə göstərilir (qalanı "See all" ilə).
    private static let previewLimit = 3
    private static let teamsLimit = 30
    private static let playersLimit = 50

    /// Sorğuya uyğun gələn ümumi sayı (limitdən əvvəl).
    private var clubMatchCount = 0
    private var playerMatchCount = 0

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
            return "Search for teams, players and leagues.\nYour recent searches will appear here."
        }
        if isSearching {
            return "Searching…"
        }
        if let remoteError {
            return remoteError.message
        }
        if SearchQuery.cleaned(trimmedQuery).count < SearchQuery.minimumLength {
            return "Type at least \(SearchQuery.minimumLength) letters to search teams and players."
        }
        return "No results for “\(trimmedQuery)”.\nCheck the spelling or try another name."
    }

    /// Komanda və oyunçu axtarışı gedir.
    var isSearching: Bool {
        remoteTask != nil
    }

    func numberOfItems(in section: Int) -> Int {
        switch sections[section] {
        case .recent: return recentSearches.count
        case .leagues: return leagueResults.count
        case .clubs: return clubResults.count
        case .players: return playerResults.count
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

    /// All tabında klub və oyunçu bölməsində limitdən çox nəticə varsa başlıqda "See all" göstərilir.
    func showsSeeAll(for section: SearchSection) -> Bool {
        guard scope == .all else { return false }
        switch section {
        case .clubs: return clubMatchCount > clubResults.count
        case .players: return playerMatchCount > playerResults.count
        default: return false
        }
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
                self.onFailed?(UserFacingError(error))
            }
        }
    }

    func updateQuery(_ text: String) {
        query = text
        startRemoteSearch()
        refresh()
    }

    func select(scope newScope: SearchScope) {
        guard newScope != scope else { return }
        scope = newScope
        refresh()
    }

    /// Axtarış faydalı olubsa (nəticə var) son axtarışlara yazılır.
    func commitQuery() {
        let hasResults = !leagueResults.isEmpty || !clubResults.isEmpty
            || !playerResults.isEmpty || !matchResults.isEmpty
        guard !trimmedQuery.isEmpty, hasResults else { return }
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

        guard !text.isEmpty else {
            leagueResults = []
            clubResults = []
            playerResults = []
            matchResults = []
            clubMatchCount = 0
            playerMatchCount = 0
            sections = recentSearches.isEmpty ? [] : [.recent]
            onChange?()
            return
        }

        let source = content ?? SearchContent(leagues: [], matchLeagues: [])
        // API artıq sorğuya uyğun olanları qaytarır, yerli filtr lazım deyil.
        let foundClubs = remote?.clubs ?? []
        let foundPlayers = remote?.players ?? []
        clubMatchCount = foundClubs.count
        playerMatchCount = foundPlayers.count

        switch scope {
        case .all:
            leagueResults = source.leagues.filter { matches($0.name, text) || matches($0.country, text) }
            clubResults = Array(foundClubs.prefix(SearchViewModel.previewLimit))
            playerResults = Array(foundPlayers.prefix(SearchViewModel.previewLimit))
            matchResults = source.matchLeagues.compactMap { league in
                let found = league.matches.filter { matches($0.home, text) || matches($0.away, text) }
                guard !found.isEmpty else { return nil }
                return League(id: league.id, name: league.name, country: league.country,
                              flag: league.flag, matches: found)
            }
        case .teams:
            leagueResults = []
            matchResults = []
            playerResults = []
            clubResults = Array(foundClubs.prefix(SearchViewModel.teamsLimit))
        case .players:
            leagueResults = []
            matchResults = []
            clubResults = []
            playerResults = Array(foundPlayers.prefix(SearchViewModel.playersLimit))
        }

        var result: [SearchSection] = []
        if !leagueResults.isEmpty { result.append(.leagues) }
        if !clubResults.isEmpty { result.append(.clubs) }
        if !playerResults.isEmpty { result.append(.players) }
        result += matchResults.indices.map { SearchSection.matches(leagueIndex: $0) }
        sections = result
        onChange?()
    }

    /// Komanda və oyunçular API-dən axtarılır (debounce ekranda edilir).
    private func startRemoteSearch() {
        remoteTask?.cancel()
        remoteTask = nil
        remoteError = nil

        let key = SearchQuery.cleaned(trimmedQuery).lowercased()
        guard key.count >= SearchQuery.minimumLength else {
            remote = nil
            return
        }
        if let cached = remoteCache[key] {
            remote = cached
            return
        }

        remote = nil
        let text = trimmedQuery
        remoteTask = Task { [weak self, service] in
            let outcome: Result<RemoteSearchResults, Error>
            do {
                outcome = .success(try await service.searchRemote(text))
            } catch {
                outcome = .failure(error)
            }
            // Yeni sorğu yazılıbsa bu cavab artıq lazım deyil.
            guard let self, !Task.isCancelled else { return }
            switch outcome {
            case .success(let results):
                self.remoteCache[key] = results
                self.remote = results
            case .failure(let error):
                self.remoteError = UserFacingError(error)
            }
            self.remoteTask = nil
            self.refresh()
        }
    }

    /// Hərf böyüklüyü və işarələr (ü, ş, ö...) nəzərə alınmır.
    private func matches(_ text: String, _ query: String) -> Bool {
        text.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
