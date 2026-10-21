//
//  AppEnvironment.swift
//  FootballApp
//
//  Created by Servan on 13.10.26.
//

//
//  AppEnvironment.swift
//  FootballApp
//

import Foundation

/// Servislərin seçildiyi və bir-birinə bağlandığı yeganə yer.
/// Ekranlar və coordinator-lar MockXService() yazmır, `AppEnvironment.current`-dən götürür.
struct AppEnvironment {

    let home: HomeProviding
    let matchDetail: MatchDetailProviding
    let explore: ExploreProviding
    let standing: StandingProviding
    let club: ClubProviding
    let player: PlayerProviding
    let search: SearchProviding

    /// Əsas dörd servis verilir; klub, oyunçu və axtarış onlardan qurulur.
    /// API-də hələ öz endpoint-i olmayan hissə mock qalır, amma əsas servislərin real datasından istifadə edir.
    init(home: HomeProviding,
         matchDetail: MatchDetailProviding,
         explore: ExploreProviding,
         standing: StandingProviding,
         club: ClubProviding? = nil,
         player: PlayerProviding? = nil,
         search: SearchProviding? = nil) {
        self.home = home
        self.matchDetail = matchDetail
        self.explore = explore
        self.standing = standing

        let club = club ?? MockClubService(standingService: standing, homeService: home)
        self.club = club
        self.player = player ?? MockPlayerService(clubService: club)
        self.search = search ?? MockSearchService(homeService: home,
                                                  exploreService: explore,
                                                  standingService: standing)
    }

    // MARK: - Hazır konfiqurasiyalar

    static var mock: AppEnvironment {
        AppEnvironment(home: MockHomeService(),
                       matchDetail: MockMatchDetailService(),
                       explore: MockExploreService(),
                       standing: MockStandingService())
    }

    /// Real API qoşulduqca mock servislər burada real servislərlə əvəz olunur (dilim-dilim).
    static var live: AppEnvironment {
        let client = APIFootballClient.shared
        let home = APIHomeService(client: client)
        let explore = MockExploreService()

        return AppEnvironment(
            home: home,
            matchDetail: APIMatchDetailService(client: client),
            explore: explore,
            standing: APIStandingService(client: client),
            club: APIClubService(client: client),
            // Axtarış öz dilimində gələcək; o vaxta qədər mock cədvəllərdə işləyir.
            search: MockSearchService(homeService: home,
                                      exploreService: explore,
                                      standingService: MockStandingService())
        )
    }

    /// Tətbiqin işlətdiyi konfiqurasiya. Xcode scheme-də `-useMockData` arqumenti mock-u məcbur edir.
    static var current: AppEnvironment = {
        ProcessInfo.processInfo.arguments.contains("-useMockData") ? .mock : .live
    }()
}
