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

extension HTTPURLResponse {
  
  var isRetriable: Bool {
    return [408, 429].contains(statusCode)
  }
  
  var isSuccessful: Bool {
    return (200..<300).contains(statusCode)
  }
  
  public var isTimeForRefreshToken: Bool {
    return [401, 403].contains(statusCode)
  }
  
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension Publisher where Output == (data: Data, response: URLResponse) {
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
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
    
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    func responseData() -> AnyPublisher<Data, HTTPError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200...299: return data
            case 401,  403:
              // wait code
              throw HTTPError.authError(response.statusCode)
            case 400...499: throw HTTPError.requestFailed(response.statusCode)
            case 500...599: throw HTTPError.serverError(response.statusCode)
            default:
                throw HTTPError.unhandledResponse("Unhandled HTTP Response Status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HTTPError }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  
  //  func refreshTokenIfNeeded(_ refreshToken: RefreshToken) -> AnyPublisher<Data, HTTPError> {
  //    // code goes here
  //    tryCatch({ error -> AnyPublisher<Data, HTTPError> in
  //      guard let apiError = error as? HTTPError, apiError.isTimeForRefreshToken else {
  //        throw error
  //      }
  //
  //      return refreshToken.refreshToken()
  //        .tryMap({ success -> AnyPublisher<Daa, HTTPError> in
  //          guard success else { throw error }
  //
  ////          return fetchURL(url)
  //        })
  //        .switchToLatest()
  //        .eraseToAnyPublisher()
  //    })
  //    .eraseToAnyPublisher()
  //  }
  
  func retryLimit(when: @escaping () -> Bool) -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
    map { (data, response) in
    
      if response.isRetriable {
            Swift.print("Simulating rate limit HTTP Response...")
            let newResponse = HTTPURLResponse(
                url: response.url!,
                statusCode: response.statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data: data, response: newResponse)
        } else {
          Swift.print("No more errors...")
            return (data: data, response: response)
        }
    }
    .eraseToAnyPublisher()
  }
  
  
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension Publisher where Output == Data, Failure == HTTPError {
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
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
