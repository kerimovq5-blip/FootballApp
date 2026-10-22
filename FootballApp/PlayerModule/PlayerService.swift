//
//  PlayerService.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

import Foundation

protocol PlayerProviding {
    func fetchPlayer(_ player: PlayerReference) async -> Result<PlayerDetailContent, Error>
}

struct APIPlayerService: PlayerProviding {

    private let client: APIFootballClient

    init(client: APIFootballClient = .shared) {
        self.client = client
    }

    func fetchPlayer(_ player: PlayerReference) async -> Result<PlayerDetailContent, Error> {
        do {
            let id = try await resolveID(for: player)
            let dto = try await client.player(id: id, season: APIConfig.season)
            return .success(APIFootballMapper.playerDetail(from: dto, reference: player, season: APIConfig.season))
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Oyunçunu tapmaq

    /// id məlumdursa birbaşa, yoxsa soyadla axtarışla (1 əlavə sorğu).
    private func resolveID(for player: PlayerReference) async throws -> Int {
        if let id = player.id { return id }

        guard let query = Self.searchText(for: player.name) else { throw APIError.notFound }
        let found = try await client.players(search: query)
        guard let match = Self.pick(from: found.map(\.player), for: player.name) else {
            throw APIError.notFound
        }
        return match.id
    }

    /// API soyadla axtarır və ən azı 3 hərf istəyir: "M. Salah" → "Salah".
    static func searchText(for name: String) -> String? {
        let folded = name.folding(options: .diacriticInsensitive, locale: nil)
        let words = folded
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { $0.count >= 3 }
        return words.last
    }

    /// Tam ad uyğun gələn, yoxsa soyadı və adının ilk hərfi uyğun gələn oyunçu.
    static func pick(from players: [PlayerDTO], for name: String) -> PlayerDTO? {
        let key = ClubKey.make(name)
        if let exact = players.first(where: { ClubKey.make($0.name ?? "") == key }) {
            return exact
        }

        let parts = name.split(separator: " ").map(String.init)
        guard let last = parts.last.map(ClubKey.make) else { return nil }
        let initial = parts.count > 1 ? parts.first.flatMap { ClubKey.make($0).first } : nil
        let candidates = players.filter { player in
            // API-də soyad uzun ola bilər ("Salah Hamed Mahrous Ghaly"), ona görə "contains".
            let surnameMatches = ClubKey.make(player.lastname ?? "").contains(last)
                || ClubKey.make(player.name ?? "").hasSuffix(last)
            guard surnameMatches else { return false }
            guard let initial else { return true }
            return ClubKey.make(player.firstname ?? player.name ?? "").first == initial
        }
        return candidates.count == 1 ? candidates.first : nil
    }
}
