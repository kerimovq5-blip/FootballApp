//
//  APIClubService.swift
//  FootballApp
//
//  Created by Servan on 15.10.26.
//


//
//  APIClubService.swift
//  FootballApp
//

import Foundation

struct APIClubService: ClubProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    func fetchClub(_ club: ClubReference,
                   completion: @escaping (Result<ClubDetailContent, Error>) -> Void) {
        resolveTeam(for: club) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let team):
                loadDetails(for: team, reference: club, completion: completion)
            }
        }
    }

    // MARK: - Komandanı tapmaq

    /// id məlumdursa birbaşa, yoxsa ad ilə axtarışla (1 əlavə sorğu).
    private func resolveTeam(for club: ClubReference,
                             completion: @escaping (Result<TeamInfoDTO, Error>) -> Void) {
        if let id = club.id {
            client.team(id: id) { result in
                switch result {
                case .success(let items):
                    if let item = items.first {
                        completion(.success(item))
                    } else {
                        completion(.failure(APIError.notFound))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }

        let query = APIClubService.searchText(for: club.name)
        client.teams(search: query) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let items):
                if let team = APIClubService.pick(from: items, for: club.name) {
                    completion(.success(team))
                    return
                }
                // Ehtiyat: ən uzun sözlə yenidən axtar (məs. "Paris Saint Germain" → "Germain").
                guard let word = APIClubService.longestWord(in: query), word != query else {
                    completion(.failure(APIError.notFound))
                    return
                }
                client.teams(search: word) { retry in
                    switch retry {
                    case .success(let retryItems):
                        if let team = APIClubService.pick(from: retryItems, for: club.name) {
                            completion(.success(team))
                        } else {
                            completion(.failure(APIError.notFound))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    /// Axtarış nəticələrindən adı tam uyğun gələn klubu seçir (milli komandalar keçilir).
    private static func pick(from items: [TeamInfoDTO], for name: String) -> TeamInfoDTO? {
        let key = ClubKey.make(name)
        let clubs = items.filter { $0.team.national != true }
        return clubs.first { ClubKey.make($0.team.name) == key } ?? clubs.first
    }

    /// API-nin axtarışı yalnız hərf, rəqəm və boşluq qəbul edir: işarələr açılır, durğu işarələri boşluğa çevrilir.
    private static func searchText(for name: String) -> String {
        let folded = name.folding(options: .diacriticInsensitive, locale: nil)
        let cleaned = String(folded.map { $0.isLetter || $0.isNumber ? $0 : " " })
        return cleaned
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func longestWord(in text: String) -> String? {
        let words = text.components(separatedBy: " ").filter { !$0.isEmpty }
        guard let word = words.max(by: { $0.count < $1.count }), word.count >= 3 else { return nil }
        return word
    }

    // MARK: - Oyunlar, cədvəllər, heyət

    /// Oyunlar, cədvəllər və heyət ardıcıl yüklənir. Biri alınmasa klub yenə açılır (boş tab ilə).
    private func loadDetails(for team: TeamInfoDTO,
                             reference: ClubReference,
                             completion: @escaping (Result<ClubDetailContent, Error>) -> Void) {
        let id = team.team.id
        let season = APIConfig.season

        client.fixtures(team: id, season: season) { fixturesResult in
            client.standings(team: id, season: season) { standingsResult in
                client.squad(team: id) { squadResult in
                    let content = APIFootballMapper.clubDetail(
                        reference: reference,
                        team: team,
                        fixtures: (try? fixturesResult.get()) ?? [],
                        standingDTOs: (try? standingsResult.get()) ?? [],
                        squad: (try? squadResult.get()) ?? []
                    )
                    completion(.success(content))
                }
            }
        }
    }
}
