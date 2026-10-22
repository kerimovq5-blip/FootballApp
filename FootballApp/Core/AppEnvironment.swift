//
//  AppEnvironment.swift
//  FootballApp
//
//  Created by Servan on 13.10.26.
//

import Foundation

/// Servislərin seçildiyi və bir-birinə bağlandığı yeganə yer.
/// Ekranlar və coordinator-lar servisi özü yaratmır, `AppEnvironment.current`-dən götürür.
/// Testlər isə ViewModel-ə öz saxta servislərini birbaşa ötürür.
struct AppEnvironment {

    let home: HomeProviding
    let matchDetail: MatchDetailProviding
    let explore: ExploreProviding
    let standing: StandingProviding
    let club: ClubProviding
    let player: PlayerProviding
    let search: SearchProviding

    /// Bütün servislər API-Football-dan oxuyur və eyni client-i (keşi) paylaşır.
    static var live: AppEnvironment {
        let client = APIFootballClient.shared
        let home = APIHomeService(client: client)

        return AppEnvironment(
            home: home,
            matchDetail: APIMatchDetailService(client: client),
            explore: APIExploreService(client: client),
            standing: APIStandingService(client: client),
            club: APIClubService(client: client),
            player: APIPlayerService(client: client),
            search: APISearchService(client: client, homeService: home)
        )
    }

    static var current: AppEnvironment = .live
}
