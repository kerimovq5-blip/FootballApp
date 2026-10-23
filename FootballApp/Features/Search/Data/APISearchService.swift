//
//  APISearchService.swift
//  FootballApp
//
//  `SearchProviding`-in API-Football implementasiyası.
//

import Foundation

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
