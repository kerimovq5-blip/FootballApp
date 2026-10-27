//
//  APIMatchDetailService.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

import Foundation

struct APIMatchDetailService: MatchDetailProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    /// 2 sorğu: oyunun özü (hadisə, heyət, statistika) və H2H. Loqoları ekran özü yükləyir.
    /// Rəsmi heyət yoxdursa əlavə olaraq təxmini heyət üçün komanda başına 2 sorğu (keşlənir).
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
            loadPredictedLineups(for: fixture) { predicted in
                completion(.success(APIFootballMapper.matchDetail(fixture: fixture,
                                                                  headToHead: h2h,
                                                                  predictedLineups: predicted)))
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

    // MARK: - Təxmini heyət

    /// Rəsmi heyət yoxdursa hər komandanın son oyunundakı heyət götürülür.
    /// Alınmasa belə oyun açılsın deyə xəta nil kimi qəbul olunur.
    private func loadPredictedLineups(for fixture: FixtureDTO, completion: @escaping (MatchLineups?) -> Void) {
        let needed = APIFootballMapper.needsPredictedLineups(fixture) || Self.forcePredictedLineups
        guard needed,
              let homeID = fixture.teams.home.id,
              let awayID = fixture.teams.away.id else {
            completion(nil)
            return
        }
        Task { @MainActor in
            completion(await predictedLineups(for: fixture, homeID: homeID, awayID: awayID))
        }
    }

    private func predictedLineups(for fixture: FixtureDTO, homeID: Int, awayID: Int) async -> MatchLineups? {
        async let home = lastLineup(teamID: homeID, before: fixture)
        async let away = lastLineup(teamID: awayID, before: fixture)
        return APIFootballMapper.predictedLineups(home: await home,
                                                  away: await away,
                                                  homeName: fixture.teams.home.name,
                                                  awayName: fixture.teams.away.name)
    }

    /// Komandanın `fixture`-dan əvvəlki son bitmiş oyunundakı başlanğıc heyəti.
    private func lastLineup(teamID: Int, before fixture: FixtureDTO) async -> LineupDTO? {
        guard let season = try? await client.fixtures(team: teamID, season: APIConfig.season),
              let last = APIFootballMapper.lastFinishedFixture(in: season, before: fixture),
              let lineups = try? await client.lineups(fixture: last.fixture.id) else { return nil }
        return lineups.first { $0.team.id == teamID }
    }

    /// Debug-da scheme-ə `-testPredictedLineups` əlavə olunsa bitmiş oyunda da təxmini heyət göstərilir
    /// (pulsuz API yalnız köhnə mövsümü verir, bütün oyunlar bitmiş olur).
    private static var forcePredictedLineups: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-testPredictedLineups")
        #else
        return false
        #endif
    }
}
