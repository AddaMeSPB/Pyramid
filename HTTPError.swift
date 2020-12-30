//
//  HTTPError.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 30.12.2020.
//

import Foundation
import Combine

public enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkError(Error)
    case authError(Int)
    case decodingError(DecodingError)
    case unhandledResponse(String)
    
    public var isRetriable: Bool {
        switch self {
        case .decodingError, .unhandledResponse:
            return false

        case .authError(let status):
          return ![401, 403].contains(status)

        case .requestFailed(let status):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return [timeoutStatus, rateLimitStatus].contains(status)

        case .serverError, .networkError, .nonHTTPResponse:
            return true
        }
    }
  
  public var isTimeForRefreshToken: Bool {
    switch self {
    case .authError(let status):
        return [401, 403].contains(status)
    case .decodingError, .unhandledResponse, .requestFailed, .serverError, .networkError, .nonHTTPResponse:
        return false
    }
  }
  
  public var description: String {
      switch self {
      case .nonHTTPResponse: return "Non-HTTP response received"
      case .requestFailed(let status): return "Received HTTP \(status)"
      case .serverError(let status): return "Server Error - \(status)"
      case .networkError(let error): return "Failed to load the request: \(error)"
      case .authError(let status): return "Authentication Token is expired: \(status)"
      case .decodingError(let decError): return "Failed to process response: \(decError)"
      case .unhandledResponse: return "Server unhandledResponse"
      }
  }
}
