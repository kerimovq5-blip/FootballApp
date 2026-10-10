//
//  SignUpViewModel.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//

import Foundation

enum SignUpViewModelState {
    case idle
    case loading
    case success
    case invalidInput(String)
    case requestFailed(Error)
}

final class SignUpViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isPrivacyChecked: Bool = false

    private(set) var state: SignUpViewModelState = .idle {
        didSet { onStateChange?() }
    }

    var onStateChange: (() -> Void)?

    weak var coordinator: AuthNavigating?

    private let service: AuthProviding

    init(service: AuthProviding) {
        self.service = service
    }

    func register() {
        if case .loading = state { return }

        if let message = FormValidator.validate([
            (name, [NotEmptyRule(fieldName: "Name")]),
            (email, [EmailRule()]),
            (password, [MinLengthRule(length: 8, fieldName: "Password")])
        ]) {
            state = .invalidInput(message)
            return
        }
        guard password == confirmPassword else {
            state = .invalidInput("Passwords do not match.")
            return
        }
        guard isPrivacyChecked else {
            state = .invalidInput("You must agree to the privacy policy.")
            return
        }

        state = .loading
        service.register(
            name: name,
            email: email,
            password: password
        ) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                RememberMeStore.update(isEnabled: true, email: self.email)
                self.state = .success
                self.coordinator?.authFinished()
            case .failure(let error):
                self.state = .requestFailed(error)
            }
        }
    }
}
