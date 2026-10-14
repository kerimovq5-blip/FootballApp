//
//  APIError.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  APIFootballClient.swift
//  FootballApp
//

import Foundation

enum APIError: LocalizedError {
    case missingKey
    case server(String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .missingKey: return "API key is missing. Add it to Core/Secrets.swift."
        case .server(let message): return message
        case .notFound: return "Not found."
        }
    }
}

final class APIFootballClient {

    static let shared = APIFootballClient()

    private let apiKey: String
    private let network: NetworkManager
    private let lock = NSLock()
    private var cache: [String: (storedAt: Date, value: Any)] = [:]

    init(apiKey: String = AppConfig.apiKey, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.network = NetworkManager(session: session,
                                      mainPath: APIConfig.baseURL,
                                      header: ["x-apisports-key": apiKey])
    }

    // MARK: - Sorğular

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

    // MARK: - Əsas çağırış

    private func call<Item: Decodable>(_ endpoint: FootballEndpoint,
                                       ttl: TimeInterval,
                                       completion: @escaping (Result<[Item], Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(APIError.missingKey))
            return
        }

        let key = cacheKey(for: endpoint)
        if let cached: [Item] = cachedValue(for: key, ttl: ttl) {
            completion(.success(cached))
            return
        }

        #if DEBUG
        print("API ▶︎ GET \(key)")
        #endif

        network.request(endPoint: endpoint) { [weak self] (result: Result<APIResponse<Item>, Error>) in
            switch result {
            case .success(let response):
                if let message = response.errors.message {
                    completion(.failure(APIError.server(message)))
                } else {
                    self?.store(response.response, for: key)
                    completion(.success(response.response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Keş (yalnız yaddaşda, tətbiq bağlananda silinir)

    private func cacheKey(for endpoint: FootballEndpoint) -> String {
        let query = endpoint.queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        return "\(endpoint.path)?\(query)"
    }

    private func cachedValue<Item>(for key: String, ttl: TimeInterval) -> [Item]? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = cache[key], Date().timeIntervalSince(entry.storedAt) < ttl else { return nil }
        return entry.value as? [Item]
    }

    private func store<Item>(_ value: [Item], for key: String) {
        lock.lock()
        cache[key] = (Date(), value)
        lock.unlock()
    }
}
