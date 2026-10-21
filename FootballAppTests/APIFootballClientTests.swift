//
//  APIFootballClientTests.swift
//  FootballAppTests
//
//  Client-in proxy-yə token ilə getdiyini və API açarı göndərmədiyini yoxlayır.
//  Şəbəkə saxta URLProtocol ilə əvəz olunur, real serverə sorğu getmir.
//

import Foundation
import Testing
@testable import FootballApp

// MARK: - Saxta şəbəkə

final class StubURLProtocol: URLProtocol {

    nonisolated(unsafe) static var response: (status: Int, body: String) = (200, "{}")
    nonisolated(unsafe) static var requests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requests.append(request)
        let http = HTTPURLResponse(url: request.url!, statusCode: Self.response.status,
                                   httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(Self.response.body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

struct FakeTokenProvider: AuthTokenProviding {
    var token: String?

    func idToken() async throws -> String {
        guard let token else { throw APIError.notSignedIn }
        return token
    }
}

// MARK: - Testlər

/// `.serialized`: saxta şəbəkə ortaq vəziyyət saxlayır, testlər növbə ilə işləməlidir.
@Suite("APIFootballClient (proxy)", .serialized)
@MainActor
struct APIFootballClientTests {

    private static let teamJSON = """
    { "errors": [], "response": [{ "team": { "id": 42, "name": "Arsenal", "country": "England",
      "founded": 1886, "national": false, "logo": null }, "venue": null }] }
    """

    private func makeClient(token: String?) -> APIFootballClient {
        StubURLProtocol.requests = []
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let client = APIFootballClient(tokenProvider: FakeTokenProvider(token: token),
                                       session: URLSession(configuration: configuration))
        client.clearCache()
        return client
    }

    /// Keşə düşməsin deyə hər testdə fərqli id.
    private var uniqueID: Int { Int.random(in: 100_000...999_999) }

    @Test("Sorğu proxy-yə Bearer token ilə gedir, API açarı göndərilmir")
    func sendsTokenToProxy() async throws {
        StubURLProtocol.response = (200, Self.teamJSON)
        let client = makeClient(token: "test-token")
        let id = uniqueID

        let teams = try await client.team(id: id)

        #expect(teams.first?.team.name == "Arsenal")
        let request = try #require(StubURLProtocol.requests.first)
        #expect(request.url?.absoluteString == "\(APIConfig.baseURL)/teams?id=\(id)")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(request.value(forHTTPHeaderField: "x-apisports-key") == nil)
    }

    @Test("İstifadəçi login olmayıbsa sorğu göndərilmir")
    func notSignedIn() async {
        let client = makeClient(token: nil)

        do {
            _ = try await client.team(id: uniqueID)
            Issue.record("Xəta gözlənilirdi")
        } catch let error as APIError {
            guard case .notSignedIn = error else {
                Issue.record("Gözlənilməyən xəta: \(error)")
                return
            }
        } catch {
            Issue.record("Gözlənilməyən xəta: \(error)")
        }
        #expect(StubURLProtocol.requests.isEmpty)
    }

    @Test("Proxy 401 qaytaranda serverin mesajı istifadəçiyə çatır")
    func expiredSession() async {
        StubURLProtocol.response = (401, """
        { "statusmessage": "Your session has expired. Please sign in again.", "status_code": 401, "success": false }
        """)
        let client = makeClient(token: "expired-token")

        do {
            _ = try await client.team(id: uniqueID)
            Issue.record("Xəta gözlənilirdi")
        } catch {
            #expect(error.localizedDescription == "Your session has expired. Please sign in again.")
        }
    }

    @Test("Eyni sorğu ikinci dəfə keşdən gəlir")
    func cachesResponses() async throws {
        StubURLProtocol.response = (200, Self.teamJSON)
        let client = makeClient(token: "test-token")
        let id = uniqueID

        _ = try await client.team(id: id)
        _ = try await client.team(id: id)

        #expect(StubURLProtocol.requests.count == 1)
    }
}
