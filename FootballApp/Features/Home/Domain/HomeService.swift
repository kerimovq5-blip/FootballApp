//
//  HomeService.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

struct HomeContent {
    let leagues: [League]
}

protocol HomeProviding {
    /// `dayOffset`: bu günə nisbətən gün fərqi (-1 dünən, 0 bu gün, 1 sabah).
    func fetchHome(dayOffset: Int, completion: @escaping (Result<HomeContent, Error>) -> Void)
}

extension HomeProviding {
    /// Bu günün oyunları (gün seçimi olmayan yerlər üçün: axtarış, klub, bildirişlər).
    func fetchHome(completion: @escaping (Result<HomeContent, Error>) -> Void) {
        fetchHome(dayOffset: 0, completion: completion)
    }
}
