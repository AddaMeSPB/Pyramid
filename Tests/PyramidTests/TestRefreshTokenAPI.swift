//
//  TestRefreshTokenAPI.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 28.12.2020.
//

import Foundation
import Pyramid

struct AuthTokenResponse: Codable {
    var accessToken: String
    var refreshToken: String
}

struct RefreshTokenInput: Codable {
    var refreshToken: String
}

enum RefreshTokenAPI {
    case refresh(token: RefreshTokenInput)
}

extension RefreshTokenAPI: APIConfiguration, RequiresAuth {
  func fetchRefreshTokenSend() -> Bool {
    return false
  }
  
    var path: String {
        return pathPrefix + {
            switch self {
            case .refresh:
                return "/refreshToken"
            }
        }()
    }
    
  var baseURL: URL { URL(string: "http://192.168.1.20:8080/v1")! }
    
    var method: HTTPMethod {
        switch self {
        case .refresh: return .post
        }
    }
    
    var dataType: DataType {
        switch self {
        case .refresh(let rToken):
            return .requestWithEncodable(encodable: AnyEncodable(rToken))
        }
    }
    
    var pathPrefix: String {
        return "auth/"
    }
    
    var contentType: ContentType? {
        switch self {
        case .refresh:
            return .applicationJson
        }
    }

}
