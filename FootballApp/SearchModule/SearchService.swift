//
//  SearchService.swift
//  FootballApp
//

import Foundation

struct PlayerSearchResult {
    let reference: PlayerReference
    let position: PlayerPosition?
    /// Bayraq emojisi; tapılmasa boş.
    let flag: String
    var nationality: String?
    var photoURL: String?
}

/// Sorğusuz yüklənən hissə: yerli siyahıda filtrlənir.
struct SearchContent {
    /// Axtarışda liqa kimi tapılan liqalar.
    let leagues: [League]
    /// Oyunları olan liqalar (Home ilə eyni mənbə).
    let matchLeagues: [League]
}

/// Sorğuya görə API-dən gələn hissə.
struct RemoteSearchResults {
    var clubs: [ClubReference] = []
    var players: [PlayerSearchResult] = []
}

protocol SearchProviding {
    /// Liqalar və bu günün oyunları (bir dəfə yüklənir).
    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void)
    /// Komanda və oyunçu axtarışı. Sorğu ən azı `SearchQuery.minimumLength` hərf olmalıdır.
    func searchRemote(_ query: String) async throws -> RemoteSearchResults
}

enum SearchQuery {
    /// API-Football komanda və oyunçu axtarışı ən azı 3 hərf istəyir.
    static let minimumLength = 3

    /// API yalnız hərf, rəqəm və boşluq qəbul edir: "Beşiktaş J.K." → "Besiktas J K".
    static func cleaned(_ text: String) -> String {
        let folded = text.folding(options: .diacriticInsensitive, locale: nil)
        return String(folded.map { $0.isLetter || $0.isNumber ? $0 : " " })
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Oyunçu soyadla axtarılır: "Mohamed Salah" → "Salah".
    static func playerSurname(_ text: String) -> String? {
        cleaned(text)
            .components(separatedBy: " ")
            .last { $0.count >= minimumLength }
    }
}

struct APISearchService: SearchProviding {

    private let client: APIFootballClient
    private let homeService: HomeProviding

    init(client: APIFootballClient = .shared, homeService: HomeProviding) {
        self.client = client
        self.homeService = homeService
    }

    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void) {
        let leagues = APILeagueCatalog.leagues
        homeService.fetchHome { result in
            // Oyunlar yüklənməsə də komanda, oyunçu və liqa axtarışı işləsin.
            let matchLeagues = (try? result.get().leagues) ?? []
            completion(.success(SearchContent(leagues: leagues, matchLeagues: matchLeagues)))
        }
    }

    func searchRemote(_ query: String) async throws -> RemoteSearchResults {
        let teamQuery = SearchQuery.cleaned(query)
        let playerQuery = SearchQuery.playerSurname(query)

        async let teamItems = searchTeams(teamQuery)
        async let playerItems = searchPlayers(playerQuery)

        // Biri alınmasa digərinin nəticəsi yenə göstərilir; ikisi də alınmasa xəta.
        var results = RemoteSearchResults()
        var firstError: Error?
        do {
            results.clubs = try await teamItems.map { item in
                ClubReference(name: item.team.name,
                              country: item.team.country,
                              flag: CountryFlag.emoji(forCountryName: item.team.country),
                              id: item.team.id)
            }
        } catch {
            firstError = error
        }
        do {
            results.players = APIFootballMapper.playerSearchResults(from: try await playerItems)
        } catch {
            firstError = firstError ?? error
        }

        if results.clubs.isEmpty, results.players.isEmpty, let firstError {
            throw firstError
        }
        return results
    }

    private func searchTeams(_ query: String) async throws -> [TeamInfoDTO] {
        guard query.count >= SearchQuery.minimumLength else { return [] }
        return try await client.teams(search: query)
    }

    private func searchPlayers(_ surname: String?) async throws -> [PlayerProfileDTO] {
        guard let surname else { return [] }
        return try await client.players(search: surname)
    }
}
