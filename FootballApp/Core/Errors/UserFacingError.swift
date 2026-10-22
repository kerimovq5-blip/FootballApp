//
//  UserFacingError.swift
//  FootballApp
//

import Foundation

/// İstənilən xətanı istifadəçinin başa düşəcəyi formaya çevirir:
/// qısa başlıq, izah, ikona və "Try again" düyməsinin mənalı olub-olmadığı.
///
/// ViewModel-lər ekrana texniki xəta (`URLError`, `DecodingError`...) yox, bunu ötürür.
struct UserFacingError: Equatable {

    enum Kind: Equatable {
        /// İnternet yoxdur.
        case offline
        /// Server cavab vermir və ya tapılmır.
        case unreachable
        /// API-nin gündəlik sorğu limiti bitib.
        case dailyLimit
        /// Bu data cari API planında yoxdur (məsələn, köhnə və ya yeni mövsüm).
        case notAvailable
        /// Login sessiyası bitib.
        case sessionExpired
        /// Axtarılan şey tapılmadı.
        case notFound
        /// Qalan hər şey.
        case generic
    }

    let kind: Kind
    let title: String
    let message: String

    /// SF Symbol adı.
    var symbolName: String {
        switch kind {
        case .offline: return "wifi.slash"
        case .unreachable: return "icloud.slash"
        case .dailyLimit: return "hourglass"
        case .notAvailable: return "lock"
        case .sessionExpired: return "person.crop.circle.badge.exclamationmark"
        case .notFound: return "magnifyingglass"
        case .generic: return "exclamationmark.triangle"
        }
    }

    /// Təkrar cəhdin faydası olmayan hallarda "Try again" göstərilmir.
    var canRetry: Bool {
        switch kind {
        case .offline, .unreachable, .generic: return true
        case .dailyLimit, .notAvailable, .sessionExpired, .notFound: return false
        }
    }

    init(kind: Kind, title: String, message: String) {
        self.kind = kind
        self.title = title
        self.message = message
    }

    init(_ error: Error) {
        self = UserFacingError.map(error)
    }

    // MARK: - Hazır mesajlar

    static let offline = UserFacingError(
        kind: .offline,
        title: "No internet connection",
        message: "Check your connection and try again."
    )

    static let unreachable = UserFacingError(
        kind: .unreachable,
        title: "Can't reach the server",
        message: "The server isn't responding. Please try again in a moment."
    )

    static let dailyLimit = UserFacingError(
        kind: .dailyLimit,
        title: "Daily limit reached",
        message: "Football data is limited on the free plan. Please try again tomorrow."
    )

    static let sessionExpired = UserFacingError(
        kind: .sessionExpired,
        title: "Please sign in again",
        message: "Your session has expired."
    )

    static let notFound = UserFacingError(
        kind: .notFound,
        title: "Not found",
        message: "We couldn't find what you were looking for."
    )

    static let unreadable = UserFacingError(
        kind: .generic,
        title: "Something went wrong",
        message: "We couldn't read the data. Please try again later."
    )

    // MARK: - Xəritələmə

    private static func map(_ error: Error) -> UserFacingError {
        if let urlError = error as? URLError {
            return map(urlError)
        }
        if let apiError = error as? APIError {
            return map(apiError)
        }
        if let localError = error as? LocalError {
            return map(localError)
        }
        if let standingError = error as? StandingError {
            return UserFacingError(kind: .notAvailable,
                                   title: "Not available",
                                   message: standingError.localizedDescription)
        }
        return UserFacingError(kind: .generic,
                               title: "Something went wrong",
                               message: error.localizedDescription)
    }

    private static func map(_ error: URLError) -> UserFacingError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
            return .offline
        case .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .secureConnectionFailed:
            return .unreachable
        default:
            return UserFacingError(kind: .generic,
                                   title: "Something went wrong",
                                   message: error.localizedDescription)
        }
    }

    private static func map(_ error: APIError) -> UserFacingError {
        switch error {
        case .notFound:
            return .notFound
        case .server(let message):
            // API-Football xətaları mətnlə gəlir; tanınanlar sadə mesaja çevrilir.
            let text = message.lowercased()
            if text.contains("request limit") {
                return .dailyLimit
            }
            if text.contains("too many requests") {
                return UserFacingError(kind: .unreachable,
                                       title: "Too many requests",
                                       message: "Please wait a minute and try again.")
            }
            if text.contains("plan") && text.contains("access") {
                return UserFacingError(kind: .notAvailable,
                                       title: "Not available",
                                       message: "This data isn't included in the current API plan.")
            }
            return UserFacingError(kind: .generic, title: "Something went wrong", message: message)
        default:
            return UserFacingError(kind: .generic,
                                   title: "Something went wrong",
                                   message: error.localizedDescription)
        }
    }

    private static func map(_ error: LocalError) -> UserFacingError {
        switch error {
        case .backEndError(let model) where model.statuscode == 401:
            return UserFacingError(kind: .sessionExpired,
                                   title: sessionExpired.title,
                                   message: model.errorDescription ?? sessionExpired.message)
        case .invalidDecode, .invalidData, .noData, .invalidResponse:
            return .unreadable
        default:
            return UserFacingError(kind: .generic,
                                   title: "Something went wrong",
                                   message: error.localizedDescription)
        }
    }
}
