//
//  UserSessionCleaner.swift
//  FootballApp
//
//  İstifadəçiyə aid lokal data (profil, son baxılan oyunlar, son axtarışlar,
//  izlənən oyunlar və xatırlatmalar) telefonda saxlanılır. Başqa hesab daxil
//  olanda əvvəlki istifadəçinin datası görünməməlidir.
//

import Foundation

final class UserSessionCleaner {

    private let profileStore: ProfileStoring
    private let activityStore: ActivityStoring
    private let recentSearches: RecentSearchStoring
    private let alerts: MatchAlertsUseCase
    private let defaults: UserDefaults

    private let lastUserIDKey = "session.lastUserID"

    init(profileStore: ProfileStoring = UserDefaultsProfileStore(),
         activityStore: ActivityStoring = UserDefaultsActivityStore.shared,
         recentSearches: RecentSearchStoring = UserDefaultsRecentSearchStore.shared,
         alerts: MatchAlertsUseCase = AppEnvironment.current.matchAlerts,
         defaults: UserDefaults = .standard) {
        self.profileStore = profileStore
        self.activityStore = activityStore
        self.recentSearches = recentSearches
        self.alerts = alerts
        self.defaults = defaults
    }

    /// Daxil olandan sonra, ekranlar qurulmazdan əvvəl çağırılır.
    /// Əvvəlki istifadəçi başqadırsa onun datası silinir, eyni istifadəçinin datası qalır.
    func prepare(forUserID userID: String?) {
        guard let userID else { return }
        // nil: tətbiq yenilənəndən sonra ilk açılış, kimin datası olduğu məlum deyil.
        if let previous = defaults.string(forKey: lastUserIDKey), previous != userID {
            clearUserData()
        }
        defaults.set(userID, forKey: lastUserIDKey)
    }

    /// "Log out" düyməsi: istifadəçiyə aid bütün lokal data silinir.
    func clearUserData() {
        profileStore.clear()
        activityStore.clear()
        recentSearches.clear()
        alerts.clearAll()
    }
}
