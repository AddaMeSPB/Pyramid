//
//  HttpUrlResponse+IsSuccesful.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
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
}

extension HTTPURLResponse {
    var isSuccessful: Bool {
        return (200..<300).contains(statusCode)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
        tryMap { (data: Data, response: URLResponse) in
            guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse }
            return (data, http)
        }
        .mapError { error in
            if error is HTTPError {
                return error as! HTTPError
            } else {
                return HTTPError.networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension Publisher where
    Output == (data: Data, response: HTTPURLResponse),
    Failure == HTTPError {
    
    func responseData() -> AnyPublisher<Data, HTTPError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200...299: return data
            case 401,  403: throw HTTPError.authError(response.statusCode)
            case 400...499: throw HTTPError.requestFailed(response.statusCode)
            case 500...599: throw HTTPError.serverError(response.statusCode)
            default:
                throw HTTPError.unhandledResponse("Unhandled HTTP Response Status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HTTPError }
        .eraseToAnyPublisher()
    }
  
  func refreshTokenIfNeeded(_ refreshToken: RefreshToken) -> AnyPublisher<Data, HTTPError> {
    // code goes here
    tryMap { (data: Data, response: HTTPURLResponse) -> Data  in
      if response.statusCode == 401 || response.statusCode == 403 {
        return  data //refreshToken
      } else {
        throw HTTPError.unhandledResponse("Unhandled HTTP Response Status code: \(response.statusCode)")
      }
    }
    .mapError { $0 as! HTTPError }
    .eraseToAnyPublisher()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension Publisher where Output == Data, Failure == HTTPError {
  func decoding<D: Decodable, Decoder: TopLevelDecoder>(_ type: D.Type, decoder: Decoder)
  -> AnyPublisher<D, HTTPError> where Decoder.Input == Data {
    decode(type: D.self, decoder: decoder)
      .mapError { error in
        if error is DecodingError {
          return HTTPError.decodingError(error as! DecodingError)
        } else {
          return error as! HTTPError
        }
        
      }
      .eraseToAnyPublisher()
  }
}
