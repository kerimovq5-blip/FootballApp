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

    /// Bir neçə günün oyunları; eyni liqanın oyunları birləşdirilir. Biri alınmasa xəta qaytarır.
    func fetchHome(dayOffsets: [Int], completion: @escaping (Result<HomeContent, Error>) -> Void) {
        var leaguesByDay: [Int: [League]] = [:]
        var firstError: Error?
        var remaining = dayOffsets.count

        for offset in dayOffsets {
            fetchHome(dayOffset: offset) { result in
                switch result {
                case .success(let content):
                    leaguesByDay[offset] = content.leagues
                case .failure(let error):
                    firstError = firstError ?? error
                }
                remaining -= 1
                guard remaining == 0 else { return }

                if let firstError {
                    completion(.failure(firstError))
                    return
                }
                var merged: [League] = []
                for league in dayOffsets.flatMap({ leaguesByDay[$0] ?? [] }) {
                    if let index = merged.firstIndex(where: { $0.id == league.id }) {
                        let existing = merged[index]
                        merged[index] = League(id: existing.id, name: existing.name, country: existing.country,
                                               flag: existing.flag, matches: existing.matches + league.matches)
                    } else {
                        merged.append(league)
                    }
                }
                completion(.success(HomeContent(leagues: merged)))
            }
        }
    }
}
