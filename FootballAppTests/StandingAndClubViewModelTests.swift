//
//  StandingAndClubViewModelTests.swift
//  FootballAppTests
//

import Foundation
import Testing
@testable import FootballApp

@Suite("StandingViewModel")
@MainActor
struct StandingViewModelTests {

    private let service: FakeStandingService
    private let viewModel: StandingViewModel

    init() {
        let service = FakeStandingService(leagues: [
            TestData.league(id: 101, name: "Premier League"),
            TestData.league(id: 102, name: "La Liga")
        ])
        service.result = .success([
            TestData.standing(position: 1, team: "Liverpool"),
            TestData.standing(position: 2, team: "Arsenal")
        ])
        self.service = service
        viewModel = StandingViewModel(service: service)
    }

    private var requestedLeagueIDs: [Int] { service.requests.map { $0.leagueID } }
    private var requestedFilters: [StandingFilter] { service.requests.map { $0.filter } }

    @Test("Liqalar servisdən götürülür")
    func leagues() {
        #expect(viewModel.leagues.map(\.id) == [101, 102])
    }

    @Test("İlk yükləmə birinci liqanın ümumi cədvəlini gətirir")
    func load() {
        var changes = 0
        viewModel.onChange = { changes += 1 }

        viewModel.load()

        #expect(requestedLeagueIDs == [101])
        #expect(requestedFilters == [.all])
        #expect(viewModel.standings.map(\.teamName) == ["Liverpool", "Arsenal"])
        #expect(viewModel.numberOfRows == 2)
        #expect(changes == 1)
    }

    @Test("Liqa dəyişəndə həmin liqanın cədvəli soruşulur")
    func selectLeague() {
        viewModel.load()
        viewModel.selectLeague(at: 1)

        #expect(requestedLeagueIDs == [101, 102])
        #expect(viewModel.selectedLeagueIndex == 1)
    }

    @Test("Eyni liqa və ya mövcud olmayan indeks yeni sorğu göndərmir")
    func invalidLeagueSelection() {
        viewModel.load()
        viewModel.selectLeague(at: 0)
        viewModel.selectLeague(at: 5)

        #expect(requestedLeagueIDs == [101])
        #expect(viewModel.selectedLeagueIndex == 0)
    }

    @Test("Filtr dəyişəndə eyni liqa yeni filtrlə soruşulur")
    func selectFilter() {
        viewModel.load()
        viewModel.select(.home)
        viewModel.select(.home)   // təkrar seçim nəzərə alınmır

        #expect(requestedFilters == [.all, .home])
        #expect(viewModel.selectedFilter == .home)
    }

    @Test("Xəta olanda mesaj ötürülür, köhnə cədvəl qalır")
    func failure() {
        viewModel.load()
        var failure: UserFacingError?
        viewModel.onFailed = { failure = $0 }

        service.result = .failure(TestError(message: "Limit reached"))
        viewModel.selectLeague(at: 1)

        #expect(failure?.message == "Limit reached")
        #expect(viewModel.numberOfRows == 2)
    }

    @Test("Liqa yoxdursa sorğu göndərilmir")
    func noLeagues() {
        let emptyService = FakeStandingService(leagues: [])
        let viewModel = StandingViewModel(service: emptyService)
        viewModel.load()
        #expect(emptyService.requests.isEmpty)
    }
}

@Suite("ClubDetailViewModel")
@MainActor
struct ClubDetailViewModelTests {

    @Test("Klub yüklənəndə məzmun ekrana ötürülür", .timeLimit(.minutes(1)))
    func loadSuccess() async {
        let service = FakeClubService(result: .success(FakeClubService.content(name: "Arsenal")))
        let viewModel = ClubDetailViewModel(club: ClubReference(name: "Arsenal"), service: service)

        // load() içəridə Task işə salır; nəticə gələnə qədər gözləyirik.
        let content: ClubDetailContent = await withCheckedContinuation { continuation in
            viewModel.onLoaded = { continuation.resume(returning: $0) }
            viewModel.load()
        }

        #expect(content.profile.name == "Arsenal")
        #expect(service.requestedNames == ["Arsenal"])
    }

    @Test("Xəta olanda mesaj ekrana ötürülür", .timeLimit(.minutes(1)))
    func loadFailure() async {
        let service = FakeClubService(result: .failure(TestError(message: "Club not found")))
        let viewModel = ClubDetailViewModel(club: ClubReference(name: "Unknown FC"), service: service)

        let error: UserFacingError = await withCheckedContinuation { continuation in
            viewModel.onFailed = { continuation.resume(returning: $0) }
            viewModel.load()
        }

        #expect(error.message == "Club not found")
    }
}
