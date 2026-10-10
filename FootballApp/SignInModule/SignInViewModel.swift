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
    var email: String = RememberMeStore.savedEmail ?? ""
    var password: String = ""
    var rememberMe: Bool = RememberMeStore.isEnabled
    
    private(set) var state: SignInViewModelState = .idle {
        didSet { onStateChange?() }
    }
    var onStateChange: (() -> Void)?
    var onPasswordResetSent: (() -> Void)?

    weak var coordinator: AuthNavigating?

    private let service: AuthProviding

    init(service: AuthProviding) {
        self.service = service
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
        service.login(
            email: email,
            password: password
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                            RememberMeStore.update(isEnabled: self.rememberMe, email: self.email)
                            self.state = .success
                            self.coordinator?.authFinished()
            case .failure(let error):
                self.state = .requestFailed(error)
            }
        }
    }

    func resetPassword() {
        if case .loading = state { return }

        if let message = FormValidator.validate([(email, [EmailRule()])]) {
            state = .invalidInput(message)
            return
        }

        state = .loading
        service.sendPasswordReset(email: email) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.state = .idle
                self.onPasswordResetSent?()
            case .failure(let error):
                self.state = .requestFailed(error)
            }
        }
    }
}
