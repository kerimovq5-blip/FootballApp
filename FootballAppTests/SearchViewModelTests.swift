//
//  SearchViewModelTests.swift
//  FootballAppTests
//

import Foundation
import Testing
@testable import FootballApp

@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    private let service: FakeSearchService
    private let recents: InMemoryRecentSearchStore

    init() {
        service = FakeSearchService(content: Self.content, remote: Self.remote)
        recents = InMemoryRecentSearchStore()
    }

    private func makeViewModel(recentItems: [String] = []) -> SearchViewModel {
        recents.clear()
        recentItems.reversed().forEach { recents.add($0) }
        return SearchViewModel(service: service, recents: recents)
    }

    /// Bölmələri müqayisə üçün mətnə çevirir (SearchSection Equatable deyil).
    private func sectionNames(_ viewModel: SearchViewModel) -> [String] {
        viewModel.sections.map { section in
            switch section {
            case .recent: return "recent"
            case .leagues: return "leagues"
            case .clubs: return "clubs"
            case .players: return "players"
            case .matches(let index): return "matches\(index)"
            }
        }
    }

    /// API axtarışının bitməsini gözləyir (testdə debounce yoxdur).
    private func search(_ viewModel: SearchViewModel, _ text: String) async {
        viewModel.updateQuery(text)
        let task = viewModel.remoteTask
        await task?.value
    }

    /// İki liqa və iki oyun (yerli siyahı).
    private static var content: SearchContent {
        SearchContent(
            leagues: [
                TestData.league(id: 39, name: "Premier League", country: "England"),
                TestData.league(id: 203, name: "Süper Lig", country: "Turkey")
            ],
            matchLeagues: [
                TestData.league(id: 39, matches: [
                    TestData.match(id: 1, home: "Arsenal", away: "Chelsea"),
                    TestData.match(id: 2, home: "Beşiktaş", away: "Galatasaray")
                ])
            ]
        )
    }

    /// 4 "Arsenal" (All tabının limiti 3-dür), türk hərfləri olan klub, üç oyunçu (API cavabı).
    private static var remote: RemoteSearchResults {
        RemoteSearchResults(
            clubs: [
                ClubReference(name: "Arsenal"),
                ClubReference(name: "Arsenal Tula"),
                ClubReference(name: "Arsenal Kyiv"),
                ClubReference(name: "Arsenal Sarandí"),
                ClubReference(name: "Beşiktaş"),
                ClubReference(name: "Chelsea")
            ],
            players: [
                PlayerSearchResult(reference: PlayerReference(name: "Bukayo Saka", id: 1),
                                   position: .forward, flag: "🏴"),
                PlayerSearchResult(reference: PlayerReference(name: "Mohamed Salah", id: 2),
                                   position: .forward, flag: "🇪🇬"),
                PlayerSearchResult(reference: PlayerReference(name: "William Saliba", id: 3),
                                   position: .defender, flag: "🇫🇷")
            ]
        )
    }

    // MARK: - Boş sorğu

    @Test("Data gəlməmiş mesaj göstərilmir")
    func noMessageBeforeLoad() {
        let viewModel = makeViewModel()
        #expect(viewModel.placeholderMessage == nil)
    }

    @Test("Sorğu boşdursa və son axtarış yoxdursa ipucu mesajı göstərilir")
    func emptyQueryWithoutRecents() {
        let viewModel = makeViewModel()
        viewModel.load()

        #expect(sectionNames(viewModel).isEmpty)
        #expect(viewModel.placeholderMessage?.hasPrefix("Search for teams") == true)
    }

    @Test("Sorğu boşdursa son axtarışlar göstərilir")
    func emptyQueryShowsRecents() {
        let viewModel = makeViewModel(recentItems: ["Saka", "Arsenal"])
        viewModel.load()

        #expect(sectionNames(viewModel) == ["recent"])
        #expect(viewModel.recentSearches == ["Saka", "Arsenal"])
        #expect(viewModel.placeholderMessage == nil)
    }

    @Test("Yalnız boşluqdan ibarət sorğu boş sayılır")
    func whitespaceQuery() {
        let viewModel = makeViewModel(recentItems: ["Saka"])
        viewModel.load()
        viewModel.updateQuery("   ")

        #expect(sectionNames(viewModel) == ["recent"])
    }

    // MARK: - Axtarış

    @Test("Liqa adına və ölkəsinə görə dərhal tapılır (API gözlənilmir)")
    func findsLeagues() {
        let viewModel = makeViewModel()
        viewModel.load()

        viewModel.updateQuery("premier")
        #expect(viewModel.leagueResults.map(\.id) == [39])

        viewModel.updateQuery("turkey")
        #expect(viewModel.leagueResults.map(\.id) == [203])
    }

    @Test("Hərf böyüklüyü və türk hərfləri nəzərə alınmır")
    func caseAndDiacriticInsensitive() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "BESIKTAS")

        #expect(viewModel.clubResults.map(\.name) == ["Beşiktaş"])
        #expect(viewModel.matchResults.first?.matches.map(\.id) == [2])
    }

    @Test("All tabında klublar 3 ilə məhdudlaşır və \"See all\" göstərilir")
    func allScopeLimit() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "arsenal")

        #expect(viewModel.clubResults.count == 3)
        #expect(viewModel.showsSeeAll(for: .clubs))
        #expect(sectionNames(viewModel) == ["clubs", "matches0"])
    }

    @Test("Teams tabında bütün klublar göstərilir, başqa heç nə yox")
    func teamsScope() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "arsenal")
        viewModel.select(scope: .teams)

        #expect(viewModel.clubResults.count == 4)
        #expect(!viewModel.showsSeeAll(for: .clubs))
        #expect(sectionNames(viewModel) == ["clubs"])
    }

    @Test("Players tabında yalnız oyunçular göstərilir")
    func playersScope() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "sal")
        viewModel.select(scope: .players)

        #expect(viewModel.playerResults.map(\.reference.name) == ["Mohamed Salah", "William Saliba"])
        #expect(sectionNames(viewModel) == ["players"])
    }

    @Test("Nəticə yoxdursa sorğunu göstərən mesaj çıxır")
    func noResults() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "xyz")

        #expect(sectionNames(viewModel).isEmpty)
        #expect(viewModel.placeholderMessage?.contains("xyz") == true)
    }

    // MARK: - API axtarışı

    @Test("3 hərfdən qısa sorğu API-yə getmir və ipucu göstərilir")
    func shortQueryDoesNotHitAPI() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("zz")

        #expect(service.remoteQueries.isEmpty)
        #expect(viewModel.remoteTask == nil)
        #expect(viewModel.placeholderMessage?.contains("at least 3 letters") == true)
    }

    @Test("Cavab gələnə qədər \"Searching…\" göstərilir")
    func searchingMessage() async {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("xyz")

        #expect(viewModel.isSearching)
        #expect(viewModel.placeholderMessage == "Searching…")

        let task = viewModel.remoteTask
        await task?.value
        #expect(!viewModel.isSearching)
    }

    @Test("Eyni sorğu ikinci dəfə API-yə göndərilmir")
    func repeatedQueryUsesCache() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "arsenal")
        await search(viewModel, "")
        await search(viewModel, "Arsenal ")

        #expect(service.remoteQueries == ["arsenal"])
        #expect(viewModel.clubResults.count == 3)
    }

    @Test("API xətası boş nəticə əvəzinə izahla göstərilir")
    func remoteFailure() async {
        service.remoteError = URLError(.notConnectedToInternet)
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "tottenham")

        #expect(sectionNames(viewModel).isEmpty)
        #expect(viewModel.placeholderMessage == UserFacingError.offline.message)
    }

    // MARK: - Son axtarışlar

    @Test("Nəticəsi olan sorğu son axtarışlara kəsilmiş şəkildə yazılır")
    func commitWithResults() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "  Saka  ")
        viewModel.commitQuery()

        #expect(recents.items == ["Saka"])
        #expect(viewModel.recentSearches == ["Saka"])
    }

    @Test("Nəticəsi olmayan sorğu son axtarışlara yazılmır")
    func commitWithoutResults() async {
        let viewModel = makeViewModel()
        viewModel.load()
        await search(viewModel, "xyz")
        viewModel.commitQuery()

        #expect(recents.items.isEmpty)
    }

    @Test("Son axtarışları təmizləmək bölməni gizlədir")
    func clearRecents() {
        let viewModel = makeViewModel(recentItems: ["Saka"])
        viewModel.load()
        viewModel.clearRecents()

        #expect(viewModel.recentSearches.isEmpty)
        #expect(recents.items.isEmpty)
        #expect(sectionNames(viewModel).isEmpty)
    }

    // MARK: - Xəta

    @Test("Data yüklənməsə xəta mesajı ötürülür")
    func loadFailure() {
        service.result = .failure(TestError(message: "Server error"))
        let viewModel = makeViewModel()
        var failure: UserFacingError?
        viewModel.onFailed = { failure = $0 }

        viewModel.load()
        #expect(failure?.message == "Server error")
    }
}
