//
//  ErrorManager.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation

public enum ErrorManager: Error {
    case parameterEncodingFailed
    case invalidServerResponseWithStatusCode(statusCode: Int)
    case invalidServerResponse
    case missingBodyData
    case failedToDecodeImage
    case decodingError(Error)
    case connectionError(Error)
    case underlying(Error)
}

public extension ErrorManager {
     var errorDescription: String {
        switch self {
        case .parameterEncodingFailed:
            return "Parameter Encoding Failed!"
        case .invalidServerResponse:
            return "Failed to parse the response to HTTPResponse"
        case .connectionError(let error):
            return "Network connection seems to be offline: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding problem: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        case .invalidServerResponseWithStatusCode(let statusCode):
            return "The server response didn't fall in the given range Status Code is: \(statusCode)"
        case .missingBodyData:
            return "No body data provided from the server"
        case .failedToDecodeImage:
            return "the body doesn't contain a valid data."
        }
    }
}

//public enum HTTPError: Error {
//    case nonHTTPResponse
//    case requestFailed(Int)
//    case serverError(Int)
//    case networkError(Error)
//    case authError(Int)
//    case decodingError(DecodingError)
//    case unhandledResponse(String)
//
//    public var isRetriable: Bool {
//        switch self {
//        case .decodingError, .unhandledResponse:
//            return false
//
//        case .authError(let status):
//          return ![401, 403].contains(status)
//
//        case .requestFailed(let status):
//            let timeoutStatus = 408
//            let rateLimitStatus = 429
//            return [timeoutStatus, rateLimitStatus].contains(status)
//
//        case .serverError, .networkError, .nonHTTPResponse:
//            return true
//        }
//    }
//
//  public var isTimeForRefreshToken: Bool {
//    switch self {
//    case .authError(let status):
//        return [401, 403].contains(status)
//    case .decodingError, .unhandledResponse, .requestFailed, .serverError, .networkError, .nonHTTPResponse:
//        return false
//    }
//  }
//
//  public var description: String {
//      switch self {
//      case .nonHTTPResponse: return "Non-HTTP response received"
//      case .requestFailed(let status): return "Received HTTP \(status)"
//      case .serverError(let status): return "Server Error - \(status)"
//      case .networkError(let error): return "Failed to load the request: \(error)"
//      case .authError(let status): return "Authentication Token is expired: \(status)"
//      case .decodingError(let decError): return "Failed to process response: \(decError)"
//      case .unhandledResponse: return "Server unhandledResponse"
//      }
//  }
//}
