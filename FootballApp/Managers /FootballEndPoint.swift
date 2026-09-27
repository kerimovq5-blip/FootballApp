//
//  FootballEndPoint.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 27.09.26.
//

import Foundation

enum FootballEndPoint : EndPoint {
    var path: String {
        ""
    }

    var method: HTTPMethod {
        return .get
    }

    var queryItems: [URLQueryItem] {
        return []
    }

    var requestBody: RequestBody? {
        return nil
    }

    
    
}
