//
//  MatchAlertsUseCase.swift
//  FootballApp
//
//  Oyunu izləmək (zəng düyməsi) və "oyun başlayır" xatırlatması. Qaydalar bir yerdədir,
//  ona görə Home, Axtarış, Bildirişlər və Settings eyni davranır və bunlar testlə yoxlanılır.
//

import Foundation

enum MatchAlertResult: Equatable {
    /// Oyun izlənir. `reminderScheduled == false`: oyun başlayıb, vaxtı məlum deyil
    /// və ya bildirişlər Settings-də söndürülüb.
    case followed(reminderScheduled: Bool)
    case unfollowed
    /// Oyun izlənir, amma istifadəçi bildiriş icazəsi verməyib.
    case permissionDenied
}

final class MatchAlertsUseCase {

    /// Xatırlatma oyundan neçə dəqiqə əvvəl gəlir.
    static let minutesBefore = 15

    private let subscriptions: MatchSubscriptionStoring
    private let reminders: MatchReminderStoring
    private let scheduler: MatchReminderScheduling
    private let settings: SettingsStoring
    private let now: () -> Date
    /// Yalnız Debug (`-testReminders`): bitmiş oyun da izlənəndə 5 saniyə sonra bildiriş gəlir.
    /// Pulsuz API köhnə mövsümü göstərdiyi üçün başqa cür yoxlamaq olmur.
    private let testMode: Bool

    init(subscriptions: MatchSubscriptionStoring,
         reminders: MatchReminderStoring,
         scheduler: MatchReminderScheduling,
         settings: SettingsStoring,
         testMode: Bool = false,
         now: @escaping () -> Date = Date.init) {
        self.subscriptions = subscriptions
        self.reminders = reminders
        self.scheduler = scheduler
        self.settings = settings
        self.testMode = testMode
        self.now = now
    }

    // MARK: - Oyunu izləmək

    func isFollowing(_ matchID: Int) -> Bool {
        subscriptions.isSubscribed(matchID)
    }

    var followedMatchIDs: Set<Int> {
        subscriptions.subscribedMatchIDs
    }

    /// Zəng düyməsi: izlənirsə dayandırır, izlənmirsə izləyir və xatırlatma qurur.
    func toggle(_ match: Match, competition: String) async -> MatchAlertResult {
        if subscriptions.isSubscribed(match.id) {
            unfollow(matchID: match.id)
            return .unfollowed
        }

        subscriptions.toggle(match.id)
        guard let kickoff = match.kickoff, testMode || !match.status.hasStarted else {
            return .followed(reminderScheduled: false)
        }
        let reminder = MatchReminder(matchID: match.id, home: match.home, away: match.away,
                                     competition: competition, kickoff: kickoff)
        reminders.save(reminder)

        guard settings.notificationsEnabled else { return .followed(reminderScheduled: false) }
        guard await scheduler.requestAuthorization() else { return .permissionDenied }
        return .followed(reminderScheduled: await schedule(reminder))
    }

    func unfollow(matchID: Int) {
        if subscriptions.isSubscribed(matchID) {
            subscriptions.toggle(matchID)
        }
        reminders.remove(matchID: matchID)
        scheduler.cancel(matchID: matchID)
    }

    // MARK: - Settings

    var notificationsEnabled: Bool {
        settings.notificationsEnabled
    }

    /// Settings-dəki "Match reminders" açarı. İcazə verilməsə `false` qaytarır və açar sönülü qalır.
    func setNotificationsEnabled(_ isEnabled: Bool) async -> Bool {
        guard isEnabled else {
            settings.notificationsEnabled = false
            scheduler.cancelAll()
            return true
        }
        guard await scheduler.requestAuthorization() else {
            settings.notificationsEnabled = false
            return false
        }
        settings.notificationsEnabled = true
        await rescheduleAll()
        return true
    }

    /// İzlənən, hələ başlamamış oyunların xatırlatmalarını yenidən qurur, keçmişdəkiləri silir.
    func rescheduleAll() async {
        guard settings.notificationsEnabled else { return }
        for reminder in reminders.reminders {
            guard subscriptions.isSubscribed(reminder.matchID) else {
                reminders.remove(matchID: reminder.matchID)
                continue
            }
            if !(await schedule(reminder)) {
                reminders.remove(matchID: reminder.matchID)
            }
        }
    }

    /// Çıxışda: izlənən oyunlar və bütün xatırlatmalar silinir.
    func clearAll() {
        subscriptions.clear()
        reminders.clear()
        scheduler.cancelAll()
    }

    // MARK: - Private

    /// Bildiriş vaxtı: oyundan 15 dəqiqə əvvəl; o vaxt keçibsə, amma oyun başlamayıbsa dərhal.
    func fireDate(for reminder: MatchReminder) -> Date? {
        let current = now()
        guard reminder.kickoff > current else {
            return testMode ? current.addingTimeInterval(5) : nil
        }
        let preferred = reminder.kickoff.addingTimeInterval(-Double(Self.minutesBefore) * 60)
        return max(preferred, current.addingTimeInterval(1))
    }

    private func schedule(_ reminder: MatchReminder) async -> Bool {
        guard let date = fireDate(for: reminder) else { return false }
        do {
            try await scheduler.schedule(reminder, at: date)
            return true
        } catch {
            return false
        }
    }
}
