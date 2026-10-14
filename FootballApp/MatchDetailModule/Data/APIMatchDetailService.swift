//
//  APIMatchDetailService.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  APIMatchDetailService.swift
//  FootballApp
//

import UIKit

struct APIMatchDetailService: MatchDetailProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    /// 2 sorğu: oyunun özü (hadisə, heyət, statistika) və H2H. Loqolar ayrıca yüklənir, kvotadan çıxmır.
    func fetchMatchDetail(id: Int, completion: @escaping (Result<MatchDetailData, Error>) -> Void) {
        client.fixture(id: id) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let fixture):
                loadExtras(for: fixture, completion: completion)
            }
        }
    }

    private func loadExtras(for fixture: FixtureDTO,
                            completion: @escaping (Result<MatchDetailData, Error>) -> Void) {
        loadHeadToHead(for: fixture) { h2h in
            ImageLoader.shared.load(fixture.teams.home.logo) { homeCrest in
                ImageLoader.shared.load(fixture.teams.away.logo) { awayCrest in
                    completion(.success(APIFootballMapper.matchDetail(fixture: fixture,
                                                                      headToHead: h2h,
                                                                      homeCrest: homeCrest,
                                                                      awayCrest: awayCrest)))
                }
            }
        }
    }

    /// H2H alınmasa belə oyun açılsın deyə xəta boş siyahı kimi qəbul olunur.
    private func loadHeadToHead(for fixture: FixtureDTO, completion: @escaping ([FixtureDTO]) -> Void) {
        guard let home = fixture.teams.home.id, let away = fixture.teams.away.id else {
            completion([])
            return
        }
        client.headToHead(home: home, away: away) { result in
            completion((try? result.get()) ?? [])
        }
    }
}