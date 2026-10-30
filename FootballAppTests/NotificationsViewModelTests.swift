//
//  NotificationViewModelTest.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.10.26.
//

//
//  NotificationsViewModelTests.swift
//  FootballAppTests
//

import Testing
@testable import FootballApp

@Suite("NotificationsViewModel")
@MainActor
struct NotificationsViewModelTests {

    private let service = FakeHomeService()
    private let subscriptions = InMemorySubscriptionStore()
    private let viewModel: NotificationsViewModel

    init() {
        let alerts = MatchAlertsUseCase(subscriptions: subscriptions,
                                        reminders: InMemoryReminderStore(),
                                        scheduler: FakeReminderScheduler(),
                                        settings: InMemorySettingsStore())
        viewModel = NotificationsViewModel(service: service, alerts: alerts)
    }

    private func league(matchIDs: [Int]) -> League {
        TestData.league(id: 39, matches: matchIDs.map {
            TestData.match(id: $0, status: .scheduled(kickoff: "21:00"))
        })
    }

    @Test("Dünən, bu gün və sabah soruşulur, izlənən oyunlar bir liqada birləşir")
    func followedMatchesFromAllDays() {
        subscriptions.toggle(1)
        subscriptions.toggle(3)

        viewModel.load()
        service.respond(0, leagues: [league(matchIDs: [1])])
        service.respond(1, leagues: [league(matchIDs: [2])])
        service.respond(2, leagues: [league(matchIDs: [3])])

        #expect(service.requestedOffsets == [-1, 0, 1])
        #expect(viewModel.leagues.map(\.id) == [39])
        #expect(viewModel.leagues.first?.matches.map(\.id) == [1, 3])
    }

    @Test("Bütün cavablar gəlməmiş ekran yenilənmir")
    func waitsForAllDays() {
        subscriptions.toggle(1)
        var changes = 0
        viewModel.onChange = { changes += 1 }

        viewModel.load()
        service.respond(0, leagues: [league(matchIDs: [1])])
        #expect(changes == 0)

        service.respond(1, leagues: [])
        service.respond(2, leagues: [])
        #expect(changes == 1)
    }

    @Test("İzlənən oyun yoxdursa sorğu getmir və siyahı boş olur")
    func noFollowedMatches() {
        var changes = 0
        viewModel.onChange = { changes += 1 }

        viewModel.load()

        #expect(service.requestedOffsets.isEmpty)
        #expect(viewModel.leagues.isEmpty)
        #expect(changes == 1)
    }

    @Test("Son oyun silinəndə gec gələn köhnə cavab onu geri qaytarmır")
    func staleResponseIgnored() {
        subscriptions.toggle(1)
        viewModel.load()

        viewModel.unsubscribe(matchID: 1)
        service.respond(0, leagues: [league(matchIDs: [1])])
        service.respond(1, leagues: [])
        service.respond(2, leagues: [])

        #expect(viewModel.leagues.isEmpty)
    }

    @Test("Bir gün alınmasa xəta bir dəfə ekrana ötürülür")
    func failure() {
        subscriptions.toggle(1)
        var messages: [String] = []
        viewModel.onFailed = { messages.append($0.message) }

        viewModel.load()
        service.respond(0, leagues: [])
        service.fail(1, message: "No internet")
        service.respond(2, leagues: [])

        #expect(messages == ["No internet"])
    }
}
