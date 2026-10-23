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

    // MARK: - Komandanı tapmaq

    /// id məlumdursa birbaşa, yoxsa ad ilə axtarışla (1 əlavə sorğu).
    private func resolveTeam(for club: ClubReference) async throws -> TeamInfoDTO {
        if let id = club.id {
            guard let item = try await client.team(id: id).first else { throw APIError.notFound }
            return item
        }

        let query = Self.searchText(for: club.name)
        let items = try await client.teams(search: query)
        if let team = Self.pick(from: items, for: club.name) { return team }

        // Ehtiyat: ən uzun sözlə yenidən axtar (məs. "Paris Saint Germain" → "Germain").
        guard let word = Self.longestWord(in: query), word != query else {
            throw APIError.notFound
        }
        let retryItems = try await client.teams(search: word)
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

        async let fixtures = try? client.fixtures(team: id, season: season)
        async let standings = try? client.standings(team: id, season: season)
        async let squad = try? client.squad(team: id)

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
