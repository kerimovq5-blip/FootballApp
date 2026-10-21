//
//  AuthTokenProvider.swift
//  FootballApp
//

import Foundation
import FirebaseAuth

/// Proxy-yə göndərilən istifadəçi token-ini verir.
/// Protokol arxasındadır ki, testlərdə Firebase olmadan saxta token ötürmək mümkün olsun.
protocol AuthTokenProviding {
    func idToken() async throws -> String
}

/// Firebase ID token-i. Firebase onu özü keşləyir və vaxtı bitəndə (1 saat) avtomatik yeniləyir.
struct FirebaseAuthTokenProvider: AuthTokenProviding {
    func idToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIError.notSignedIn
        }
        return try await user.getIDToken()
    }
}
