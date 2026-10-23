//
//  MatchAlertsUseCaseTests.swift
//  FootballAppTests
//
//  Zəng düyməsi və "oyun başlayır" xatırlatması qaydaları.
//

import Foundation
import Testing
@testable import FootballApp

@Suite("MatchAlertsUseCase")
@MainActor
struct MatchAlertsUseCaseTests {

    /// Testlərdə "indi" sabitdir: 2024-10-19 12:00 UTC.
    private static let now = Date(timeIntervalSince1970: 1_729_339_200)

    private let scheduler = FakeReminderScheduler()
    private let subscriptions = InMemorySubscriptionStore()
    private let reminders = InMemoryReminderStore()
    private let settings = InMemorySettingsStore()

    private func makeUseCase(testMode: Bool = false) -> MatchAlertsUseCase {
        MatchAlertsUseCase(subscriptions: subscriptions, reminders: reminders, scheduler: scheduler,
                           settings: settings, testMode: testMode, now: { Self.now })
    }

    private func match(id: Int = 1,
                       startsIn minutes: Double = 120,
                       status: MatchStatus = .scheduled(kickoff: "14:00")) -> Match {
        Match(id: id, home: "Arsenal", away: "Chelsea", homeScore: nil, awayScore: nil,
              status: status, kickoff: Self.now.addingTimeInterval(minutes * 60))
    }

    // MARK: - İzləmək

    @Test("Gələcək oyun izlənəndə xatırlatma 15 dəqiqə əvvələ qurulur")
    func followUpcoming() async {
        let useCase = makeUseCase()
        let result = await useCase.toggle(match(startsIn: 120), competition: "Premier League")

        #expect(result == .followed(reminderScheduled: true))
        #expect(useCase.isFollowing(1))
        #expect(scheduler.scheduled.first?.date == Self.now.addingTimeInterval(105 * 60))
        #expect(reminders.reminders.first?.competition == "Premier League")
    }

    @Test("Oyuna 15 dəqiqədən az qalıbsa xatırlatma dərhal gəlir")
    func followSoon() async {
        let useCase = makeUseCase()
        _ = await useCase.toggle(match(startsIn: 5), competition: "Premier League")

        #expect(scheduler.scheduled.first?.date == Self.now.addingTimeInterval(1))
    }

    @Test("Başlamış oyun izlənir, amma xatırlatma qurulmur və icazə soruşulmur")
    func followStarted() async {
        let useCase = makeUseCase()
        let result = await useCase.toggle(match(startsIn: -30, status: .live(minute: "30'")),
                                          competition: "Premier League")

        #expect(result == .followed(reminderScheduled: false))
        #expect(useCase.isFollowing(1))
        #expect(scheduler.scheduled.isEmpty)
        #expect(scheduler.authorizationRequests == 0)
    }

    @Test("İkinci toxunuş izləməni dayandırır və xatırlatmanı silir")
    func unfollow() async {
        let useCase = makeUseCase()
        _ = await useCase.toggle(match(), competition: "Premier League")
        let result = await useCase.toggle(match(), competition: "Premier League")

        #expect(result == .unfollowed)
        #expect(!useCase.isFollowing(1))
        #expect(scheduler.cancelledIDs == [1])
        #expect(reminders.reminders.isEmpty)
    }

    @Test("İcazə verilməsə oyun yenə izlənir, nəticə permissionDenied olur")
    func permissionDenied() async {
        scheduler.isAuthorized = false
        let useCase = makeUseCase()
        let result = await useCase.toggle(match(), competition: "Premier League")

        #expect(result == .permissionDenied)
        #expect(useCase.isFollowing(1))
        #expect(scheduler.scheduled.isEmpty)
    }

    @Test("Settings-də xatırlatmalar söndürülübsə icazə soruşulmur")
    func remindersDisabled() async {
        settings.notificationsEnabled = false
        let useCase = makeUseCase()
        let result = await useCase.toggle(match(), competition: "Premier League")

        #expect(result == .followed(reminderScheduled: false))
        #expect(scheduler.authorizationRequests == 0)
        #expect(reminders.reminders.count == 1)   // açılanda qurulmaq üçün saxlanılır
    }

    // MARK: - Settings

    @Test("Xatırlatmaları söndürmək hamısını ləğv edir")
    func turnOff() async {
        let useCase = makeUseCase()
        let isAllowed = await useCase.setNotificationsEnabled(false)

        #expect(isAllowed)
        #expect(!settings.notificationsEnabled)
        #expect(scheduler.cancelAllCount == 1)
    }

    @Test("Yenidən açanda izlənən gələcək oyunlar qurulur, keçmişdəkilər silinir")
    func turnOnReschedules() async {
        settings.notificationsEnabled = false
        let useCase = makeUseCase()
        _ = await useCase.toggle(match(id: 1, startsIn: 120), competition: "Premier League")
        reminders.save(MatchReminder(matchID: 2, home: "A", away: "B", competition: "C",
                                     kickoff: Self.now.addingTimeInterval(-3600)))
        subscriptions.toggle(2)

        let isAllowed = await useCase.setNotificationsEnabled(true)

        #expect(isAllowed)
        #expect(scheduler.scheduled.map(\.matchID) == [1])
        #expect(reminders.reminders.map(\.matchID) == [1])
    }

    @Test("Açanda icazə verilməsə açar sönülü qalır")
    func turnOnDenied() async {
        settings.notificationsEnabled = false
        scheduler.isAuthorized = false
        let useCase = makeUseCase()

        let isAllowed = await useCase.setNotificationsEnabled(true)
        #expect(!isAllowed)
        #expect(!settings.notificationsEnabled)
    }

    // MARK: - Digər

    @Test("Oyunun başlama vaxtı API cavabından oxunur")
    func kickoffFromAPI() {
        let match = APIFootballMapper.mapMatch(TestData.fixture(date: "2024-10-19T14:00:00+00:00", status: "NS"))
        #expect(match.kickoff == Self.now.addingTimeInterval(2 * 60 * 60))
    }

    @Test("Test rejimində bitmiş oyun üçün də 5 saniyə sonra bildiriş gəlir")
    func testMode() async {
        let useCase = makeUseCase(testMode: true)
        _ = await useCase.toggle(match(startsIn: -600, status: .finished), competition: "Premier League")

        #expect(scheduler.scheduled.first?.date == Self.now.addingTimeInterval(5))
    }

    @Test("Çıxışda izlənən oyunlar və xatırlatmalar silinir")
    func clearAll() async {
        let useCase = makeUseCase()
        _ = await useCase.toggle(match(), competition: "Premier League")
        useCase.clearAll()

        #expect(useCase.followedMatchIDs.isEmpty)
        #expect(reminders.reminders.isEmpty)
        #expect(scheduler.cancelAllCount == 1)
    }
}
