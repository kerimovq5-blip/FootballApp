//
//  SignUpViewModel.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//

import  Foundation

enum SignUpViewModelState {
    case idle
    case loading
    case success
    case invalidInput(String)
    case reqquestFailed
}

final class SignUpViewModel {
    var name : String = ""
    var email : String = ""
    var password : String = ""
    var isPrivacyChecked : Bool = false
    
    private(set) var state: SignUpViewModelState = .idle {
        didSet{ onStateChange?() }
    }
    
    var onStateChange: (() -> Void)?
    var onRegisterSucceeded: ((_ email: String, _ name: String) -> Void)?
    
    weak var coordinator: AuthNavigating?
    
    
    func register () {
        guard isPrivacyChecked else {
            state = .invalidInput("You must agree to the privacy policy")
            return
        }
       
    }
}
