//
//  ValidationPattern.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 05.10.26.
//

import Foundation

protocol ValidationPattern {
    func validate(_ value: String) -> String?
}

struct EmailRule: ValidationPattern {
    func validate(_ value: String) -> String? {
        
        Validator.isValidEmail(email: value) ? nil : "Email is not valid."
    }
}

struct MinLengthRule: ValidationPattern {
    let length: Int
    let fieldName: String
    func validate(_ value: String) -> String? {
        value.count >= length ? nil : "\(fieldName) must be at least \(length) characters."
    }
}

struct NotEmptyRule: ValidationPattern {
    let fieldName: String
    func validate(_ value: String) -> String? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(fieldName) must not be empty." : nil
    }
}

enum FormValidator {
    static func validate(_ fields: [(value: String, rules: [ValidationPattern])]) -> String? {
        for field in fields {
            for rule in field.rules {
                if let message = rule.validate(field.value) {
                    return message
                }
            }
        }
        return nil
    }
}
