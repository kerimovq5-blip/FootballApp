//
//  APIFootballClient.swift
//  FootballApp
//

import Foundation

enum APIError: LocalizedError {
    case notSignedIn
    case server(String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Please sign in to continue."
        case .server(let message): return message
        case .notFound: return "Not found."
        }
    }
}

/// API-Football datası. Sorğular birbaşa API-yə yox, Firebase proxy-yə gedir
/// (`functions/`): API açarı serverdədir, tətbiq yalnız istifadəçinin ID token-ini göndərir.
final class APIFootballClient {

    static let shared = APIFootballClient()

    private let tokenProvider: AuthTokenProviding
    private let network: NetworkManager
    private let lock = NSLock()
    private var memory: [String: (storedAt: Date, value: Any)] = [:]
    private let cacheDirectory: URL?

    init(tokenProvider: AuthTokenProviding = FirebaseAuthTokenProvider(),
         session: URLSession = .shared) {
        self.tokenProvider = tokenProvider
        self.network = NetworkManager(session: session,
                                      mainPath: APIConfig.baseURL,
                                      header: [:])

        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("APIFootballCache", isDirectory: true)
        if let directory {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.cacheDirectory = directory
    }

    // MARK: - Sorğular (completion, köhnə ekranlar üçün)

    /// Bir tarixdəki bütün oyunlar (hamısı bir sorğuda; liqalara görə sonra süzülür).
    func fixtures(date: String, completion: @escaping (Result<[FixtureDTO], Error>) -> Void) {
        call(.fixtures(date: date, timezone: TimeZone.current.identifier),
             ttl: 10 * 60,
             completion: completion)
    }

    /// Tək oyun: hadisələr, heyətlər və statistika da bu cavabdadır.
    func fixture(id: Int, completion: @escaping (Result<FixtureDTO, Error>) -> Void) {
        call(.fixture(id: id), ttl: 2 * 60) { (result: Result<[FixtureDTO], Error>) in
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
    }

    func headToHead(home: Int, away: Int, completion: @escaping (Result<[FixtureDTO], Error>) -> Void) {
        call(.headToHead(home: home, away: away, last: 10), ttl: 24 * 60 * 60, completion: completion)
    }

    /// Liqa cədvəli. All, Home və Away eyni cavabdan hesablanır, ona görə bir sorğu kifayətdir.
    func standings(league: Int, season: Int, completion: @escaping (Result<[StandingsDTO], Error>) -> Void) {
        call(.standings(league: league, season: season), ttl: 6 * 60 * 60, completion: completion)
    }

    /// Klubun iştirak etdiyi bütün turnirlərin cədvəlləri (bir sorğuda).
    func standings(team: Int, season: Int, completion: @escaping (Result<[StandingsDTO], Error>) -> Void) {
        call(.teamStandings(team: team, season: season), ttl: 6 * 60 * 60, completion: completion)
    }

    func team(id: Int, completion: @escaping (Result<[TeamInfoDTO], Error>) -> Void) {
        call(.team(id: id), ttl: 7 * 24 * 60 * 60, completion: completion)
    }

    func teams(search: String, completion: @escaping (Result<[TeamInfoDTO], Error>) -> Void) {
        call(.teamSearch(name: search), ttl: 7 * 24 * 60 * 60, completion: completion)
    }

    /// Klubun mövsümdəki bütün oyunları.
    func fixtures(team: Int, season: Int, completion: @escaping (Result<[FixtureDTO], Error>) -> Void) {
        call(.teamFixtures(team: team, season: season), ttl: 60 * 60, completion: completion)
    }

    func squad(team: Int, completion: @escaping (Result<[SquadDTO], Error>) -> Void) {
        call(.squad(team: team), ttl: 24 * 60 * 60, completion: completion)
    }

    // MARK: - Sorğular (async/await)

    func fixtures(date: String) async throws -> [FixtureDTO] {
        try await fetch(.fixtures(date: date, timezone: TimeZone.current.identifier), ttl: 10 * 60)
    }

    func fixture(id: Int) async throws -> FixtureDTO {
        let items: [FixtureDTO] = try await fetch(.fixture(id: id), ttl: 2 * 60)
        guard let item = items.first else { throw APIError.notFound }
        return item
    }

    func headToHead(home: Int, away: Int) async throws -> [FixtureDTO] {
        try await fetch(.headToHead(home: home, away: away, last: 10), ttl: 24 * 60 * 60)
    }

    func standings(league: Int, season: Int) async throws -> [StandingsDTO] {
        try await fetch(.standings(league: league, season: season), ttl: 6 * 60 * 60)
    }

    func standings(team: Int, season: Int) async throws -> [StandingsDTO] {
        try await fetch(.teamStandings(team: team, season: season), ttl: 6 * 60 * 60)
    }

    func team(id: Int) async throws -> [TeamInfoDTO] {
        try await fetch(.team(id: id), ttl: 7 * 24 * 60 * 60)
    }

    func teams(search: String) async throws -> [TeamInfoDTO] {
        try await fetch(.teamSearch(name: search), ttl: 7 * 24 * 60 * 60)
    }

    func fixtures(team: Int, season: Int) async throws -> [FixtureDTO] {
        try await fetch(.teamFixtures(team: team, season: season), ttl: 60 * 60)
    }

    func squad(team: Int) async throws -> [SquadDTO] {
        try await fetch(.squad(team: team), ttl: 24 * 60 * 60)
    }

    // MARK: - Əsas çağırış

    /// Keşdə varsa keşdən, yoxsa şəbəkədən. Hər iki yol (async və completion) bundan keçir.
    private func fetch<Item: Codable>(_ endpoint: FootballEndpoint,
                                      ttl: TimeInterval) async throws -> [Item] {
        let key = cacheKey(for: endpoint)
        if let cached: [Item] = cachedValue(for: key, ttl: ttl) {
            return cached
        }

        #if DEBUG
        print("API ▶︎ GET \(key)")
        #endif

        do {
            let token = try await tokenProvider.idToken()
            let response: APIResponse<Item> = try await network.request(
                endPoint: endpoint,
                extraHeaders: ["Authorization": "Bearer \(token)"]
            )
            if let message = response.errors.message {
                #if DEBUG
                print("API ✗ \(key): \(message)")
                #endif
                throw APIError.server(message)
            }
            store(response.response, for: key)
            return response.response
        } catch {
            #if DEBUG
            if !(error is APIError) {
                print("API ✗ \(key): \(error.localizedDescription)")
            }
            #endif
            throw error
        }
    }

    /// Completion versiyası. Keşdə olan cavab əvvəlki kimi dərhal (sinxron) qaytarılır,
    /// ona görə ekranlarda "loading" yanıb-sönməsi olmur.
    private func call<Item: Codable>(_ endpoint: FootballEndpoint,
                                     ttl: TimeInterval,
                                     completion: @escaping (Result<[Item], Error>) -> Void) {
        if let cached: [Item] = cachedValue(for: cacheKey(for: endpoint), ttl: ttl) {
            completion(.success(cached))
            return
        }
        Task { @MainActor in
            do {
                let items: [Item] = try await fetch(endpoint, ttl: ttl)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Keş (yaddaşda və diskdə)

    /// Diskdəki keşi silir (məsələn, yeni mövsümə keçəndə).
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        memory.removeAll()
        guard let cacheDirectory,
              let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory,
                                                                       includingPropertiesForKeys: nil) else { return }
        files.forEach { try? FileManager.default.removeItem(at: $0) }
    }

    private struct CacheEnvelope<Item: Codable>: Codable {
        let storedAt: Date
        let items: [Item]
    }

    private func cacheKey(for endpoint: FootballEndpoint) -> String {
        let query = endpoint.queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        return "\(endpoint.path)?\(query)"
    }

    private func fileURL(for key: String) -> URL? {
        guard let cacheDirectory,
              let name = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else { return nil }
        return cacheDirectory.appendingPathComponent(name).appendingPathExtension("json")
    }

    private func cachedValue<Item: Codable>(for key: String, ttl: TimeInterval) -> [Item]? {
        lock.lock()
        defer { lock.unlock() }

        if let entry = memory[key],
           Date().timeIntervalSince(entry.storedAt) < ttl,
           let items = entry.value as? [Item] {
            return items
        }

        guard let url = fileURL(for: key),
              let data = try? Data(contentsOf: url),
              let envelope = try? JSONDecoder().decode(CacheEnvelope<Item>.self, from: data),
              Date().timeIntervalSince(envelope.storedAt) < ttl else { return nil }

        memory[key] = (envelope.storedAt, envelope.items)
        return envelope.items
    }

    private func store<Item: Codable>(_ items: [Item], for key: String) {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        memory[key] = (now, items)
        if let url = fileURL(for: key),
           let data = try? JSONEncoder().encode(CacheEnvelope(storedAt: now, items: items)) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
