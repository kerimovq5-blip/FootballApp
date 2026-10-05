//
//  SignInViewModel.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//

import Foundation

enum SignInViewModelState {
    case idle
    case loading
    case success
    case invalidInput(String)
    case requestFailed(Error)
}

final class SignInViewModel {
    var email: String = ""
    var password: String = ""

    private(set) var state: SignInViewModelState = .idle {
        didSet { onStateChange?() }
    }
    var onStateChange: (() -> Void)?

    var onEmailNotVerified: ((_ email: String) -> Void)?

    weak var coordinator: AuthNavigating?

    private let service: AuthProviding
    private let sessionStore: SessionStoring

    init(service: AuthProviding, sessionStore: SessionStoring) {
        self.service = service
        self.sessionStore = sessionStore
    }

    func login() {
        if case .loading = state { return }

        if let message = FormValidator.validate([
            (email, [EmailRule()]),
            (password, [MinLengthRule(length: 8, fieldName: "Password")])
        ]) {
            state = .invalidInput(message)
            return
        }

        state = .loading
        service.login(email: email, password: password) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let session):
                self.sessionStore.save(token: session.token)
                self.state = .success
                self.coordinator?.authFinished()
            case .failure(let error):
                self.state = .requestFailed(error)
            }
        }
    }
}
