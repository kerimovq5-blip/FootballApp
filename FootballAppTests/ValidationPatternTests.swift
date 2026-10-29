//
//  ValidationPatternTests..swift
//  FootballAppTests
//
//  Created by Kerimov Qehreman on 29.10.26.
//

import Testing
@testable import FootballApp

@Suite("ValidationPattern")
@MainActor
struct ValidationPatternTests {

    @Test("Düzgün email keçir, səhv email mesaj qaytarır")
    func email() {
        #expect(EmailRule().validate("user@mail.com") == nil)
        #expect(EmailRule().validate("user@") == "Email is not valid.")
    }

    @Test("Qısa mətn üçün minimum uzunluq mesajı")
    func minLength() {
        let rule = MinLengthRule(length: 6, fieldName: "Password")
        #expect(rule.validate("12345") == "Password must be at least 6 characters.")
        #expect(rule.validate("123456") == nil)
    }

    @Test("Boş və yalnız boşluqdan ibarət mətn boş sayılır", arguments: ["", "   ", "\n"])
    func notEmpty(value: String) {
        #expect(NotEmptyRule(fieldName: "Name").validate(value) == "Name must not be empty.")
    }

    @Test("FormValidator ilk səhvi qaytarır")
    func firstError() {
        let message = FormValidator.validate([
            ("", [NotEmptyRule(fieldName: "Name")]),
            ("bad", [EmailRule()])
        ])
        #expect(message == "Name must not be empty.")
    }
}
