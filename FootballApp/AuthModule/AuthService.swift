//
//  AuthService.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//


import Foundation

struct AuthSession {
    let token: String
    let name: String?
    let email: String
}

protocol AuthProviding {
    func login(email: String,
               password: String,
               completion: @escaping (Result<AuthSession, Error>) -> Void)

    func register(name: String,
                  email: String,
                  password: String,
                  completion: @escaping (Result<AuthSession, Error>) -> Void)
    
    func logout( completion: @escaping (Result<Void, Error>) -> Void)
}

/// Real API gələnə qədər müvəqqəti implementasiya.
struct MockAuthService: AuthProviding {

    func login(email: String,
               password: String,
               completion: @escaping (Result<AuthSession, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(AuthSession(token: "mock-token", name: nil, email: email)))
        }
    }

    func register(name: String,
                  email: String,
                  password: String,
                  completion: @escaping (Result<AuthSession, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(AuthSession(token: "mock-token", name: name, email: email)))
        }
    }
    
    func logout(completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
}
