//
//  EndPoint.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 27.09.26.
//

import UIKit

protocol EndPoint {
    var path : String { get }
    var method : HTTPMethod { get  }
    var queryItems : [URLQueryItem] { get  }
    var requestBody : RequestBody? { get  }
    var requestAuth : Bool { get  }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum RequestBody {
    case rawdata(Data)
    case encodable(Encodable)
    case dictionary([String: Encodable])
}

struct ErrorModel : LocalizedError, Decodable {
    let statusmessage: String?
    private(set) var statuscode: Int?
    let success: Bool?
    let failure: Bool?
    
    enum CodingKeys: String, CodingKey {
        case statusmessage
        case statuscode = "status_code"
        case success
        case failure
    }
    
    mutating func setStatusCode(statusCode: Int) {
        if self.statuscode == nil {
            self.statuscode = statusCode
        }
    }
    
    var errorDescription: String? {
        if let statusmessage, !statusmessage.isEmpty {
            return statusmessage
        }
        if let statuscode {
            return "Error with status code: \(statuscode)"
        }
        return "Unknown error"
    }
}

 struct ProblemDetails: Decodable, Error, Sendable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let errorCode: String?
}
