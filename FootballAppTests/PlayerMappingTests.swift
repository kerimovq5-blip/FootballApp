//
//  PlayerMappingTests.swift
//  FootballAppTests
//
//  Oyunçu cavablarının (API-Football /players, /players/topscorers, /players/profiles)
//  oxunması və ekran modelinə çevrilməsi.
//

import Foundation
import Testing
@testable import FootballApp

@Suite("Oyunçu: decode və mapping")
@MainActor
struct PlayerMappingTests {

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    /// İki turnir: Premier League (əsas klub) və Champions League. Bəzi rəqəmlər mətn kimi gəlir.
    private static let salahJSON = """
    {
      "player": { "id": 306, "name": "M. Salah", "firstname": "Mohamed", "lastname": "Salah Hamed Mahrous Ghaly",
                  "age": 32, "nationality": "Egypt", "height": "175 cm",
                  "photo": "https://media.api-sports.io/football/players/306.png" },
      "statistics": [
        { "team": { "id": 40, "name": "Liverpool", "logo": null },
          "league": { "id": 39, "name": "Premier League", "country": "England", "season": 2024 },
          "games": { "appearences": 10, "lineups": 9, "minutes": 850, "number": 11,
                     "position": "Attacker", "rating": "7.500000" },
          "shots": { "total": 30, "on": 15 },
          "goals": { "total": 8, "conceded": 0, "assists": 5, "saves": null },
          "passes": { "total": 300, "key": 20, "accuracy": "79" },
          "tackles": { "total": 5, "interceptions": 2 },
          "duels": { "total": 40, "won": 18 },
          "fouls": { "drawn": 9, "committed": 4 },
          "cards": { "yellow": 1, "red": 0 },
          "penalty": { "scored": 2, "saved": null } },
        { "team": { "id": 40, "name": "Liverpool", "logo": null },
          "league": { "id": 2, "name": "UEFA Champions League", "country": "World", "season": 2024 },
          "games": { "appearences": 2, "lineups": 2, "minutes": 180, "number": 11,
                     "position": "Attacker", "rating": "6.500000" },
          "shots": { "total": 4, "on": 2 },
          "goals": { "total": 1, "conceded": 0, "assists": 0, "saves": null },
          "passes": { "total": 60, "key": 3, "accuracy": 80 },
          "tackles": { "total": null, "interceptions": null },
          "duels": { "total": 10, "won": 4 },
          "fouls": { "drawn": 2, "committed": 1 },
          "cards": { "yellow": 0, "red": 0 },
          "penalty": { "scored": 0, "saved": null } },
        { "team": { "id": 40, "name": "Liverpool", "logo": null },
          "league": { "id": 45, "name": "FA Cup", "country": "England", "season": 2024 },
          "games": { "appearences": 0, "lineups": 0, "minutes": 0, "number": null,
                     "position": "Attacker", "rating": null },
          "goals": { "total": null, "conceded": null, "assists": null, "saves": null } }
      ]
    }
    """

    // MARK: - Decode

    @Test("Rəqəm mətn kimi gəlsə də oxunur, null nil olur")
    func flexibleNumbers() throws {
        let dto = try decode(PlayerStatsDTO.self, Self.salahJSON)
        #expect(dto.statistics[0].passes?.accuracy?.value == 79)
        #expect(dto.statistics[1].passes?.accuracy?.value == 80)
        #expect(dto.statistics[0].goals?.saves?.value == nil)
    }

    // MARK: - Oyunçu səhifəsi

    @Test("Profil: klub, nömrə, mövqe, bayraq və şəkil")
    func profile() throws {
        let dto = try decode(PlayerStatsDTO.self, Self.salahJSON)
        let content = APIFootballMapper.playerDetail(from: dto,
                                                     reference: PlayerReference(name: "M. Salah"),
                                                     season: 2024)
        let profile = content.profile

        #expect(profile.name == "M. Salah")
        #expect(profile.club.name == "Liverpool")
        #expect(profile.club.id == 40)
        #expect(profile.number == 11)
        #expect(profile.position == .forward)
        #expect(profile.flag == "🇪🇬")
        #expect(profile.height == "175 cm")
        #expect(profile.photoURL?.hasSuffix("306.png") == true)
        #expect(content.season == "2024/25")
    }

    @Test("Xülasə bütün turnirlərin cəmidir, reytinq oyun sayına görə ortalamadır")
    func summary() throws {
        let dto = try decode(PlayerStatsDTO.self, Self.salahJSON)
        let content = APIFootballMapper.playerDetail(from: dto, reference: PlayerReference(name: "Salah"),
                                                     season: 2024)
        let values = Dictionary(uniqueKeysWithValues: content.summary.map { ($0.label, $0.value) })

        #expect(values["Matches"] == "12")
        #expect(values["Goals"] == "9")
        #expect(values["Assists"] == "5")
        // (7.5 × 10 + 6.5 × 2) / 12 = 7.33
        #expect(values["Rating"] == "7.33")
    }

    @Test("Oynamadığı turnir siyahıda göstərilmir, faiz düzgün hesablanır")
    func sections() throws {
        let dto = try decode(PlayerStatsDTO.self, Self.salahJSON)
        let content = APIFootballMapper.playerDetail(from: dto, reference: PlayerReference(name: "Salah"),
                                                     season: 2024)

        let competitions = content.statistics.first { $0.title == "Competitions" }
        #expect(competitions?.rows.map(\.label) == ["Premier League", "UEFA Champions League"])
        #expect(competitions?.rows.first?.value == "10 apps, 8 goals")

        let defending = content.statistics.first { $0.title == "Defending" }
        let duels = defending?.rows.first { $0.label == "Duels won" }
        #expect(duels?.value == "44%")     // 22 / 50
        #expect(content.statistics.contains { $0.title == "Attacking" })
        #expect(!content.statistics.contains { $0.title == "Goalkeeping" })
    }

    @Test("Statistikası olmayan oyunçu üçün \"–\" göstərilir")
    func noStatistics() throws {
        let dto = try decode(PlayerStatsDTO.self, """
        { "player": { "id": 1, "name": "Young Player", "age": 18, "nationality": "Azerbaijan" },
          "statistics": [] }
        """)
        let content = APIFootballMapper.playerDetail(from: dto,
                                                     reference: PlayerReference(name: "Young Player",
                                                                                clubName: "Qarabağ"),
                                                     season: 2024)
        #expect(content.profile.club.name == "Qarabağ")
        #expect(content.profile.flag == "🇦🇿")
        #expect(content.summary.first { $0.label == "Matches" }?.value == "–")
    }

    // MARK: - Explore

    @Test("Bombardirlər sıra, klub, qol və oyunçu id-si ilə gəlir")
    func topScorers() throws {
        let dto = try decode(PlayerStatsDTO.self, Self.salahJSON)
        let entries = APIFootballMapper.topPlayers(from: [dto, dto], kind: .goals)

        #expect(entries.map(\.rank) == [1, 2])
        #expect(entries.first?.subtitle == "Liverpool")
        #expect(entries.first?.value == "8")
        #expect(entries.first?.player?.id == 306)

        let assists = APIFootballMapper.topPlayers(from: [dto], kind: .assists)
        #expect(assists.first?.value == "5")
    }

    // MARK: - Axtarış

    @Test("Sorğu API-nin qəbul etdiyi formaya salınır")
    func searchQuery() {
        #expect(SearchQuery.cleaned("Beşiktaş J.K.") == "Besiktas J K")
        #expect(SearchQuery.playerSurname("Mohamed Salah") == "Salah")
        #expect(SearchQuery.playerSurname("M. Salah") == "Salah")
        #expect(SearchQuery.playerSurname("Li") == nil)
    }

    @Test("Adla açılan oyunçu (id-siz) tam ad və ya ad hərfi + soyadla tapılır")
    func pickPlayer() throws {
        let players = try decode([PlayerProfileDTO].self, """
        [ { "player": { "id": 1, "name": "Mohamed Salah", "firstname": "Mohamed", "lastname": "Salah" } },
          { "player": { "id": 2, "name": "Ahmed Salah", "firstname": "Ahmed", "lastname": "Salah" } } ]
        """).map(\.player)

        #expect(APIPlayerService.pick(from: players, for: "Mohamed Salah")?.id == 1)
        #expect(APIPlayerService.pick(from: players, for: "A. Salah")?.id == 2)
        // İki "Salah" var, ad hərfi olmadan hansı olduğu bilinmir.
        #expect(APIPlayerService.pick(from: players, for: "Salah") == nil)
    }

    @Test("Ölkə adından bayraq tapılır")
    func countryFlags() {
        #expect(CountryFlag.emoji(forCountryName: "Brazil") == "🇧🇷")
        #expect(CountryFlag.emoji(forCountryName: "England") == "🏴󠁧󠁢󠁥󠁮󠁧󠁿")
        #expect(CountryFlag.emoji(forCountryName: "Côte d'Ivoire") == "🇨🇮")
        #expect(CountryFlag.emoji(forCountryName: "Atlantis") == nil)
        #expect(CountryFlag.emoji(forCountryName: nil) == nil)
    }
}
