//
//  AuthService.swift
//  FootballApp
//

import Foundation
import FirebaseAuth

// MARK: - Model

/// Firebase manages the tokens itself (stored in the Keychain),
/// so the app only needs to know who the user is.
struct AuthSession {
    let uid: String
    let name: String?
    let email: String
}

// MARK: - Protocol

protocol AuthProviding {
    /// The signed-in user, if any (read from Firebase's persisted session).
    var currentUser: AuthSession? { get }

    func login(email: String,
               password: String,
               completion: @escaping (Result<AuthSession, Error>) -> Void)

    func register(name: String,
                  email: String,
                  password: String,
                  completion: @escaping (Result<AuthSession, Error>) -> Void)

    func sendPasswordReset(email: String,
                           completion: @escaping (Result<Void, Error>) -> Void)

    func logout(completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Firebase implementation

struct FirebaseAuthService: AuthProviding {

    var currentUser: AuthSession? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthSession(uid: user.uid, name: user.displayName, email: user.email ?? "")
    }

    func login(email: String,
               password: String,
               completion: @escaping (Result<AuthSession, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(AuthError(error)))
                return
            }
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            completion(.success(AuthSession(uid: user.uid,
                                            name: user.displayName,
                                            email: user.email ?? email)))
        }
    }

    func register(name: String,
                  email: String,
                  password: String,
                  completion: @escaping (Result<AuthSession, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(AuthError(error)))
                return
            }
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            // The account already exists at this point; a failed name update is not fatal.
            let change = user.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges { _ in
                completion(.success(AuthSession(uid: user.uid,
                                                name: name,
                                                email: user.email ?? email)))
            }
        }
    }

    func sendPasswordReset(email: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(.failure(AuthError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(AuthError(error)))
        }
    }
}

// MARK: - Errors

/// Maps Firebase error codes to messages the user can understand.
enum AuthError: LocalizedError {
    case invalidEmail
    case wrongCredentials
    case emailAlreadyInUse
    case weakPassword
    case userDisabled
    case network
    case tooManyRequests
    case unknown

    init(_ error: Error) {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode.Code(rawValue: nsError.code) else {
            self = .unknown
            return
        }
        switch code {
        case .invalidEmail:
            self = .invalidEmail
        case .wrongPassword, .invalidCredential, .userNotFound:
            self = .wrongCredentials
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .weakPassword:
            self = .weakPassword
        case .userDisabled:
            self = .userDisabled
        case .networkError:
            self = .network
        case .tooManyRequests:
            self = .tooManyRequests
        default:
            self = .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidEmail:      return "Email format is invalid."
        case .wrongCredentials:  return "Email or password is incorrect."
        case .emailAlreadyInUse: return "This email is already registered."
        case .weakPassword:      return "Password is too weak. Use at least 8 characters."
        case .userDisabled:      return "This account has been disabled."
        case .network:           return "No internet connection. Please try again."
        case .tooManyRequests:   return "Too many attempts. Please try again later."
        case .unknown:           return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Mock (kept for previews / tests)

struct MockAuthService: AuthProviding {

    var currentUser: AuthSession? {
        AuthSession(uid: "mock-uid", name: "Test User", email: "test@example.com")
    }

    func login(email: String,
               password: String,
               completion: @escaping (Result<AuthSession, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(AuthSession(uid: "mock-uid", name: nil, email: email)))
        }
    }

    func register(name: String,
                  email: String,
                  password: String,
                  completion: @escaping (Result<AuthSession, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(AuthSession(uid: "mock-uid", name: name, email: email)))
        }
    }

    func sendPasswordReset(email: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
