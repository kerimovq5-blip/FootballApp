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
        service = FakeSearchService(content: Self.content)
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

    /// 4 "Arsenal" (All tabının limiti 3-dür), türk hərfləri olan klub, iki liqa, iki oyun.
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
            ],
            clubs: [
                ClubReference(name: "Arsenal"),
                ClubReference(name: "Arsenal Tula"),
                ClubReference(name: "Arsenal Kyiv"),
                ClubReference(name: "Arsenal Sarandí"),
                ClubReference(name: "Beşiktaş"),
                ClubReference(name: "Chelsea")
            ],
            players: [
                PlayerSearchResult(reference: PlayerReference(name: "Bukayo Saka", clubName: "Arsenal"),
                                   position: .forward, flag: "🏴"),
                PlayerSearchResult(reference: PlayerReference(name: "Mohamed Salah", clubName: "Liverpool"),
                                   position: .forward, flag: "🇪🇬"),
                PlayerSearchResult(reference: PlayerReference(name: "William Saliba", clubName: "Arsenal"),
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

    @Test("Liqa adına və ölkəsinə görə tapılır")
    func findsLeagues() {
        let viewModel = makeViewModel()
        viewModel.load()

        viewModel.updateQuery("premier")
        #expect(viewModel.leagueResults.map(\.id) == [39])

        viewModel.updateQuery("turkey")
        #expect(viewModel.leagueResults.map(\.id) == [203])
    }

    @Test("Hərf böyüklüyü və türk hərfləri nəzərə alınmır")
    func caseAndDiacriticInsensitive() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("BESIKTAS")

        #expect(viewModel.clubResults.map(\.name) == ["Beşiktaş"])
        #expect(viewModel.matchResults.first?.matches.map(\.id) == [2])
    }

    @Test("All tabında klublar 3 ilə məhdudlaşır və \"See all\" göstərilir")
    func allScopeLimit() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("arsenal")

        #expect(viewModel.clubResults.count == 3)
        #expect(viewModel.showsSeeAll(for: .clubs))
        #expect(sectionNames(viewModel) == ["clubs", "matches0"])
    }

    @Test("Teams tabında bütün klublar göstərilir, başqa heç nə yox")
    func teamsScope() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("arsenal")
        viewModel.select(scope: .teams)

        #expect(viewModel.clubResults.count == 4)
        #expect(!viewModel.showsSeeAll(for: .clubs))
        #expect(sectionNames(viewModel) == ["clubs"])
    }

    @Test("Players tabında yalnız oyunçular göstərilir")
    func playersScope() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("sa")
        viewModel.select(scope: .players)

        #expect(viewModel.playerResults.map(\.reference.name) == ["Bukayo Saka", "Mohamed Salah", "William Saliba"])
        #expect(sectionNames(viewModel) == ["players"])
    }

    @Test("Nəticə yoxdursa sorğunu göstərən mesaj çıxır")
    func noResults() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("xyz")

        #expect(sectionNames(viewModel).isEmpty)
        #expect(viewModel.placeholderMessage?.contains("xyz") == true)
    }

    // MARK: - Son axtarışlar

    @Test("Nəticəsi olan sorğu son axtarışlara kəsilmiş şəkildə yazılır")
    func commitWithResults() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("  Saka  ")
        viewModel.commitQuery()

        #expect(recents.items == ["Saka"])
        #expect(viewModel.recentSearches == ["Saka"])
    }

    @Test("Nəticəsi olmayan sorğu son axtarışlara yazılmır")
    func commitWithoutResults() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateQuery("xyz")
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
