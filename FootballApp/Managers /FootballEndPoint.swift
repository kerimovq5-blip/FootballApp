//
//  FootballEndPoint.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 27.09.26.
//

import Foundation


enum FootballEndPoint : EndPoint {

    case register(name: String, email: String, password: String)
    case login(email: String, password: String)
    case verifyEmail(email: String, otp: String)
    case resendOtp(email: String)
    case refresh(refreshToken: String)
    case logout(refreshToken: String)
    case forgotPassword(email: String)
    case resetPassword(email: String, otp: String, newPassword: String)
    
    var path: String {
        switch self {
        case .register:
            return "/register"
        case .login:
            return "/login"
        case .verifyEmail:
            return "/verify-email"
        case .resendOtp:
            return "/resend-otp"
        case .refresh:
            return "/refresh"
        case .logout:
            return "/logout"
        case .forgotPassword:
            return "/forgot-password"
        case .resetPassword:
            return "/reset-password"
        }
        
    }

    var method: HTTPMethod {
        switch self {
        case .register,
                .login,
                .verifyEmail,
                .resendOtp,
                .forgotPassword,
                .resetPassword ,
                .refresh,
                .logout:
            return .post
       
        }
         
    }

    /// URLQueryItem dəyərləri düzgün encode edir (email-dəki "+", "&", boşluq və s. URL-i pozmur).
    var queryItems: [URLQueryItem] {
        switch self {
        case .logout(let refreshToken):
            return [URLQueryItem(name: "refreshToken", value: refreshToken)]
        case .forgotPassword(let email):
            return [URLQueryItem(name: "email", value: email)]
        case .resetPassword(let email, let otp, let newPassword):
            return [
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "otp", value: otp),
                URLQueryItem(name: "newPassword", value: newPassword)
            ]
        case .register, .login, .verifyEmail, .resendOtp, .refresh:
            return []
        }
    }

    var requestBody: RequestBody? {
        switch self {
        case .register(let name, let email, let password):
            return .dictionary(["name": name, "email": email, "password": password])
        case .login(let email, let password):
            return .dictionary(["email": email, "password": password])
        case .verifyEmail(let email, let otp):
            return .dictionary(["email": email, "otp": otp])
        case .resendOtp(let email):
            return .dictionary(["email": email])
        case .forgotPassword(let email):
            return .dictionary(["email": email])
        case .refresh(let refreshToken):
            return .dictionary(["refreshToken": refreshToken])
        case .logout(let refreshToken):
            return .dictionary(["refreshToken": refreshToken])
        case .resetPassword(let email, let otp, let newPassword):
            return .dictionary(["email": email, "otp": otp, "newPassword": newPassword])
        }
    }

    var requestAuth: Bool {
        switch self {
            case .register,
                .login,
                .verifyEmail,
                .resendOtp,
                .forgotPassword,
                .resetPassword,
                .refresh,
                .logout:
            return true
            
        }
    }
}

