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
        case .logout(refreshToken: let refreshToken):
            return "/logout?refreshToken=\(refreshToken)"
      
        case .forgotPassword(email: let email):
           return "/forgot-password?email=\(email)"
        case .resetPassword(
            email: let email,
            otp: let otp,
            newPassword: let newPassword
        ):
            return "/reset-password?email=\(email)&otp=\(otp)&newPassword=\(newPassword)"
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

    var queryItems: [URLQueryItem] {
        //switch self { }
        return []
    }

    var requestBody: RequestBody? {
        switch self {
        case .register(let name , let email , let password) :
            return .dictionary(
                [name: " name " , email: " email " , password: " password "]
            )
        case .login(email: let email, password: let password):
            return .dictionary([email :" email " , password: " password "])
        case .verifyEmail(email: let email, otp: let otp):
            return .dictionary([email: " email " , otp :" otp "])
        case .resendOtp(email: let email):
            return .dictionary([email: " email "])
        case .forgotPassword(email: let email):
            return .dictionary([email: " email "])
        
        case .refresh(refreshToken: let refreshToken):
            return .dictionary([refreshToken: " refreshToken "])
        case .logout(refreshToken: let refreshToken):
            return .dictionary([refreshToken: " refreshToken "])
        case .resetPassword(
            email: let email,
            otp: let otp,
            newPassword: let newPassword
        ):
            return .dictionary(
                [
                    email: " email " ,
                    otp: " otp " ,
                    newPassword: " newPassword "
                ]
            )
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
