//
//  UserSessionCleanerTests.swift
//  FootballAppTests
//
//  Başqa istifadəçi daxil olanda əvvəlkinin datası silinir, eyni istifadəçinin datası qalır.
//

import Foundation
import Testing
@testable import FootballApp

@Suite("UserSessionCleaner")
@MainActor
struct UserSessionCleanerTests {

    private let profile = SpyProfileStore()
    private let activity = SpyActivityStore()
    private let recents = InMemoryRecentSearchStore(items: ["Arsenal"])
    private let subscriptions = InMemorySubscriptionStore()
    private let defaults = UserDefaults(suiteName: "UserSessionCleanerTests.\(UUID().uuidString)")!

    private func makeCleaner() -> UserSessionCleaner {
        let alerts = MatchAlertsUseCase(subscriptions: subscriptions,
                                        reminders: InMemoryReminderStore(),
                                        scheduler: FakeReminderScheduler(),
                                        settings: InMemorySettingsStore())
        return UserSessionCleaner(profileStore: profile, activityStore: activity,
                                  recentSearches: recents, alerts: alerts, defaults: defaults)
    }

    @Test("Başqa istifadəçi daxil olanda əvvəlkinin datası silinir")
    func differentUserClearsData() {
        let cleaner = makeCleaner()
        cleaner.prepare(forUserID: "ali")
        subscriptions.toggle(10)

        cleaner.prepare(forUserID: "veli")

        #expect(profile.clearCount == 1)
        #expect(activity.clearCount == 1)
        #expect(recents.items.isEmpty)
        #expect(subscriptions.subscribedMatchIDs.isEmpty)
    }

    @Test("Eyni istifadəçi yenidən daxil olanda data qalır")
    func sameUserKeepsData() {
        let cleaner = makeCleaner()
        cleaner.prepare(forUserID: "ali")
        subscriptions.toggle(10)

        cleaner.prepare(forUserID: "ali")

        #expect(profile.clearCount == 0)
        #expect(recents.items == ["Arsenal"])
        #expect(subscriptions.subscribedMatchIDs == [10])
    }

    @Test("Tətbiq yenilənəndən sonra ilk girişdə data silinmir")
    func firstLaunchKeepsData() {
        makeCleaner().prepare(forUserID: "ali")

        #expect(profile.clearCount == 0)
        #expect(recents.items == ["Arsenal"])
    }

    @Test("Log out hər şeyi silir")
    func logoutClearsEverything() {
        subscriptions.toggle(10)

        makeCleaner().clearUserData()

        #expect(profile.clearCount == 1)
        #expect(activity.clearCount == 1)
        #expect(recents.items.isEmpty)
        #expect(subscriptions.subscribedMatchIDs.isEmpty)
    }
}

// MARK: - Test doubles

private final class SpyProfileStore: ProfileStoring {
    private(set) var clearCount = 0
    func load(email: String) -> ProfileInfo? { nil }
    func save(_ profile: ProfileInfo) {}
    func clear() { clearCount += 1 }
}

private final class SpyActivityStore: ActivityStoring {
    private(set) var clearCount = 0
    func record(matchID: Int, title: String, subtitle: String) {}
    func recent() -> [ActivityItem] { [] }
    func clear() { clearCount += 1 }
}
