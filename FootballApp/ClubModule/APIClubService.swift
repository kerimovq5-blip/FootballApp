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

    func fetchClub(_ club: ClubReference) async -> Result<ClubDetailContent, Error> {
        do {
            let team = try await resolveTeam(for: club)
            let content = await loadDetails(for: team, reference: club)
            return .success(content)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Körpü: closure → async

    private func bridge<T>(
        _ call: (@escaping (Result<T, Error>) -> Void) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            call { continuation.resume(with: $0) }
        }
    }

    // MARK: - Komandanı tapmaq

    /// id məlumdursa birbaşa, yoxsa ad ilə axtarışla (1 əlavə sorğu).
    private func resolveTeam(for club: ClubReference) async throws -> TeamInfoDTO {
        if let id = club.id {
            let items: [TeamInfoDTO] = try await bridge { done in
                client.team(id: id) { done($0) }
            }
            guard let item = items.first else { throw APIError.notFound }
            return item
        }

        let query = Self.searchText(for: club.name)
        let items: [TeamInfoDTO] = try await bridge { done in
            client.teams(search: query) { done($0) }
        }
        if let team = Self.pick(from: items, for: club.name) { return team }

        // Ehtiyat: ən uzun sözlə yenidən axtar (məs. "Paris Saint Germain" → "Germain").
        guard let word = Self.longestWord(in: query), word != query else {
            throw APIError.notFound
        }
        let retryItems: [TeamInfoDTO] = try await bridge { done in
            client.teams(search: word) { done($0) }
        }
        guard let team = Self.pick(from: retryItems, for: club.name) else {
            throw APIError.notFound
        }
        return team
    }

    // MARK: - Oyunlar, cədvəllər, heyət

    /// Üç sorğu paralel gedir. Biri alınmasa klub yenə açılır (boş tab ilə).
    private func loadDetails(for team: TeamInfoDTO,
                             reference: ClubReference) async -> ClubDetailContent {
        let id = team.team.id
        let season = APIConfig.season

        async let fixtures: [FixtureDTO]? = try? bridge { done in
            client.fixtures(team: id, season: season) { done($0) }
        }
        async let standings: [StandingsDTO]? = try? bridge { done in
            client.standings(team: id, season: season) { done($0) }
        }
        async let squad: [SquadDTO]? = try? bridge { done in
            client.squad(team: id) { done($0) }
        }

        return APIFootballMapper.clubDetail(
            reference: reference,
            team: team,
            fixtures: await fixtures ?? [],
            standingDTOs: await standings ?? [],
            squad: await squad ?? []
        )
    }

    // MARK: - Köməkçilər (dəyişməyib)

    private static func pick(from items: [TeamInfoDTO], for name: String) -> TeamInfoDTO? {
        let key = ClubKey.make(name)
        let clubs = items.filter { $0.team.national != true }
        return clubs.first { ClubKey.make($0.team.name) == key } ?? clubs.first
    }

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
}
