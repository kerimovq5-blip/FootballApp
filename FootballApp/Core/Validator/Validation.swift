//
//  Validation.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//

import UIKit
@MainActor
enum Validator{
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(password: String) -> Bool {
        return password.count >= 8
    }
}
@MainActor
final class FieldValidationController {
    
    private let textField: UITextField
    private let validator: (String) -> Bool

    private let checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()

    var isValid: Bool {
        guard let text = textField.text else { return false }
        return validator(text)
    }

    init(textField: UITextField, validator: @escaping (String) -> Bool) {
        self.textField = textField
        self.validator = validator
        configure()
    }

    private func configure() {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
        checkButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        container.addSubview(checkButton)
        textField.rightView = container
        textField.rightViewMode = .always
    }

    func markSubmitAttempt() {
        textField.layer.borderColor = isValid
            ? UIColor.clear.cgColor
        : UIColor.green.cgColor
    }

    @objc private func textChanged() {
        let text = textField.text ?? ""

        guard !text.isEmpty else {
            checkButton.setImage(nil, for: .normal)
            textField.layer.borderColor = UIColor.lightGray.cgColor
            return
        }

        if validator(text) {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = .systemGreen
            textField.layer.borderColor =  UIColor.lightGray.cgColor
        } else {
            checkButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            checkButton.tintColor = UIColor.green
            textField.layer.borderColor = UIColor.green.cgColor
        }
    }
}

extension FieldValidationController {

    static func email(textField: UITextField) -> FieldValidationController {
        FieldValidationController(textField: textField, validator: Validator.isValidEmail)
    }

    static func password(textField: UITextField) -> FieldValidationController {
        FieldValidationController(textField: textField, validator: Validator.isValidPassword)
    }

    static func minLength(_ minLength: Int, textField: UITextField) -> FieldValidationController {
        FieldValidationController(textField: textField) { $0.count >= minLength }
    }

}
