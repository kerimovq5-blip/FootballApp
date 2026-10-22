//
//  CrashReportingTests.swift
//  FootballAppTests
//
//  Crashlytics-ə yalnız araşdırılmalı xətalar getməlidir; internet/limit kimi
//  gözlənilən hallar dashboard-u doldurmamalıdır.
//

import Foundation
import Testing
@testable import FootballApp

@Suite("Crashlytics: hansı xətalar qeyd olunur")
@MainActor
struct CrashReportingTests {

    @Test("Oxunmayan və ya gözlənilməz cavab qeyd olunur",
          arguments: [LocalError.invalidDecode, .invalidData, .invalidResponse, .invalidURL])
    func unexpectedErrorsAreRecorded(error: LocalError) {
        #expect(APIFootballClient.isUnexpected(error))
    }

    @Test("İnternet problemləri qeyd olunmur",
          arguments: [URLError.Code.notConnectedToInternet, .timedOut, .networkConnectionLost])
    func networkErrorsAreNotRecorded(code: URLError.Code) {
        #expect(!APIFootballClient.isUnexpected(URLError(code)))
    }

    @Test("API-nin öz xəta mesajları (limit, plan) qeyd olunmur")
    func apiMessagesAreNotRecorded() {
        #expect(!APIFootballClient.isUnexpected(APIError.server("You have reached the request limit for the day")))
        #expect(!APIFootballClient.isUnexpected(APIError.notFound))
    }

    @Test("Serverin izah etdiyi xəta (ErrorModel) qeyd olunmur")
    func backendErrorIsNotRecorded() throws {
        let model = try JSONDecoder().decode(ErrorModel.self, from: Data("""
        { "statusmessage": "Bad request", "status_code": 400 }
        """.utf8))
        #expect(!APIFootballClient.isUnexpected(LocalError.backEndError(model)))
        #expect(!APIFootballClient.isUnexpected(LocalError.noData))
    }
}
