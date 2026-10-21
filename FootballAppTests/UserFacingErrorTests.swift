//
//  UserFacingErrorTests.swift
//  FootballAppTests
//

import Foundation
import Testing
@testable import FootballApp

@Suite("UserFacingError")
@MainActor
struct UserFacingErrorTests {

    // MARK: - Şəbəkə

    @Test("İnternet yoxdursa \"No internet connection\" və Try again",
          arguments: [URLError.Code.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed])
    func offline(code: URLError.Code) {
        let error = UserFacingError(URLError(code))
        #expect(error == .offline)
        #expect(error.canRetry)
        #expect(error.symbolName == "wifi.slash")
    }

    @Test("Server cavab vermirsə \"Can't reach the server\"",
          arguments: [URLError.Code.timedOut, .cannotFindHost, .cannotConnectToHost])
    func unreachable(code: URLError.Code) {
        let error = UserFacingError(URLError(code))
        #expect(error == .unreachable)
        #expect(error.canRetry)
    }

    // MARK: - API-Football

    @Test("Gündəlik limit bitəndə Try again göstərilmir")
    func dailyLimit() {
        let error = UserFacingError(APIError.server(
            "You have reached the request limit for the day, Go to https://dashboard.api-football.com to upgrade your plan."
        ))
        #expect(error == .dailyLimit)
        #expect(!error.canRetry)
    }

    @Test("Dəqiqəlik limit: bir az gözləyib yenidən cəhd etmək olar")
    func rateLimit() {
        let error = UserFacingError(APIError.server("Too many requests. You have exceeded the limit of requests per minute."))
        #expect(error.kind == .unreachable)
        #expect(error.title == "Too many requests")
        #expect(error.canRetry)
    }

    @Test("Pulsuz planda olmayan mövsüm \"Not available\" sayılır")
    func notAvailableOnPlan() {
        let error = UserFacingError(APIError.server("Free plans do not have access to this season, try from 2022 to 2024."))
        #expect(error.kind == .notAvailable)
        #expect(!error.canRetry)
    }

    @Test("Tanınmayan API mesajı olduğu kimi göstərilir")
    func unknownAPIMessage() {
        let error = UserFacingError(APIError.server("Something unusual happened."))
        #expect(error.kind == .generic)
        #expect(error.message == "Something unusual happened.")
        #expect(error.canRetry)
    }

    @Test("Tapılmayan data \"Not found\" olur")
    func notFound() {
        #expect(UserFacingError(APIError.notFound) == .notFound)
    }

    // MARK: - Şəbəkə qatı

    @Test("Oxunmayan cavab texniki detal göstərmədən izah olunur")
    func unreadableResponse() {
        #expect(UserFacingError(LocalError.invalidDecode) == .unreadable)
        #expect(UserFacingError(LocalError.invalidResponse) == .unreadable)
    }

    @Test("Server 401 qaytaranda sessiya bitmiş sayılır və serverin mesajı göstərilir")
    func sessionExpired() throws {
        let model = try JSONDecoder().decode(ErrorModel.self, from: Data("""
        { "statusmessage": "Your session has expired. Please sign in again.", "status_code": 401 }
        """.utf8))
        let error = UserFacingError(LocalError.backEndError(model))

        #expect(error.kind == .sessionExpired)
        #expect(error.message == "Your session has expired. Please sign in again.")
        #expect(!error.canRetry)
    }

    // MARK: - Digər

    @Test("Mock cədvəldə olmayan liqa \"Not available\" olur")
    func standingNotFound() {
        let error = UserFacingError(StandingError.leagueNotFound)
        #expect(error.kind == .notAvailable)
        #expect(error.message == StandingError.leagueNotFound.localizedDescription)
    }

    @Test("Naməlum xəta ümumi başlıq və öz mesajı ilə göstərilir")
    func unknownError() {
        let error = UserFacingError(TestError(message: "Disk is full"))
        #expect(error.kind == .generic)
        #expect(error.title == "Something went wrong")
        #expect(error.message == "Disk is full")
    }
}
