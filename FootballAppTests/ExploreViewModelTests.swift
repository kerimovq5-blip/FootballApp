//
//  ExploreViewModelTests.swift
//  FootballAppTests
//

import Foundation
import Testing
@testable import FootballApp

@Suite("ExploreViewModel")
@MainActor
struct ExploreViewModelTests {

    private let service: FakeExploreService
    private let viewModel: ExploreViewModel

    init() {
        service = FakeExploreService(leagues: [
            TestData.league(id: 39, name: "Premier League"),
            TestData.league(id: 140, name: "La Liga", country: "Spain")
        ])
        service.result = .success([
            FakeExploreService.entry(rank: 1, name: "Erling Haaland"),
            FakeExploreService.entry(rank: 2, name: "Mohamed Salah")
        ])
        viewModel = ExploreViewModel(service: service)
    }

    /// Reytinq sorğusunun bitməsini gözləyir.
    private func select(_ tab: ExploreTab) async {
        await waitUntilLoaded { viewModel.select(tab) }
    }

    private func waitUntilLoaded(_ action: () -> Void) async {
        await withCheckedContinuation { continuation in
            var resumed = false
            let finish = {
                guard !resumed else { return }
                resumed = true
                continuation.resume()
            }
            viewModel.onChange = finish
            viewModel.onFailed = { _ in finish() }
            action()
        }
    }

    @Test("Leagues tab-ı sorğusuz servisin liqalarını göstərir")
    func leaguesTab() {
        viewModel.load()
        #expect(viewModel.numberOfRows == 2)
        #expect(service.requests.isEmpty)
        #expect(viewModel.selectedLeague?.id == 39)
    }

    @Test("Top scorers seçiləndə birinci liqanın bombardirləri yüklənir", .timeLimit(.minutes(1)))
    func topScorers() async {
        await select(.topScorers)

        #expect(service.requests.count == 1)
        #expect(service.requests.first?.kind == .goals)
        #expect(service.requests.first?.leagueID == 39)
        #expect(viewModel.rankings.map(\.name) == ["Erling Haaland", "Mohamed Salah"])
        #expect(viewModel.numberOfRows == 2)
    }

    @Test("Eyni tab və liqa yenidən açılanda sorğu göndərilmir", .timeLimit(.minutes(1)))
    func cache() async {
        await select(.topScorers)
        viewModel.select(.leagues)
        await select(.topScorers)

        #expect(service.requests.count == 1)
        #expect(viewModel.rankings.count == 2)
    }

    @Test("Liqa dəyişəndə həmin liqa soruşulur", .timeLimit(.minutes(1)))
    func changeLeague() async {
        await select(.topAssists)
        await waitUntilLoaded { viewModel.selectLeague(at: 1) }

        #expect(service.requests.map(\.leagueID) == [39, 140])
        #expect(service.requests.last?.kind == .assists)
        #expect(viewModel.selectedLeague?.id == 140)
    }

    @Test("Eyni liqa və ya mövcud olmayan indeks sorğu göndərmir")
    func invalidLeagueSelection() {
        viewModel.selectLeague(at: 0)
        viewModel.selectLeague(at: 9)
        #expect(service.requests.isEmpty)
    }

    @Test("Xəta olanda mesaj ötürülür", .timeLimit(.minutes(1)))
    func failure() async {
        service.result = .failure(URLError(.notConnectedToInternet))
        var failure: UserFacingError?
        await withCheckedContinuation { continuation in
            viewModel.onFailed = { error in
                failure = error
                continuation.resume()
            }
            viewModel.select(.topScorers)
        }
        #expect(failure == .offline)
        #expect(viewModel.rankings.isEmpty)
    }
}
