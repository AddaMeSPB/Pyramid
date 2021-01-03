import Foundation
#if canImport(Combine)
import Combine
#endif

public struct Prefference {
  public var isDebuggingEnabled: Bool = false
}

public typealias VoidResultCompletion = (Result<Response, ErrorManager>) -> Void

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public protocol RefreshToken {
  associatedtype Decodable
  func refreshToken<S: Subject>(using subject: S) where S.Output == Decodable
  func tokenSubject() -> CurrentValueSubject<Decodable, Never>
}

public protocol AuthToken {
  var accessToken: String? { get } //CurrentValueSubject<String?, Never> { get }
  var refreshToken: String? { get } // CurrentValueSubject<String?, Never> { get }
}

public struct AuthTokenResponse: AuthToken {
  public var accessToken: String?
  
  public var refreshToken: String?
  
//  public var refreshToken: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)
//  public var accessToken: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)
}

open class Authenticator: RefreshToken {
  public var currentToken = AuthTokenResponse()
  
  public func refreshToken<S: Subject>(using subject: S) where S.Output == AuthTokenResponse {
    self.currentToken = AuthTokenResponse(accessToken: """
  eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdGF0dXMiOjAsImV4cCI6MTY5NTIyODEwMiwiaWF0IjoxNjA4OTE0NTAyLCJ1c2VySWQiOiI1ZmFiYjA1ZDI0NzBjMTc5MTliM2MwZTIiLCJwaG9uZU51bWJlciI6Iis3OTIxODgyMTIxOSJ9.Q9iP6VihNsDxshTns-hnXP9Ux6k6vhpZTlZ2c7b0hQVVR1wFre-trODMGvYsLJEonRU23P7wJGO3-KLluh-SeOwQK4mUJo4SzKlAUT4aWME3YDDRaNqpkF6HDIBs9OKsG2Fmr-Z_wTy-R2szGP7aD_lJDDvqRVufcYyEMpqjDj9JDk0xsDKsRlv-iePmYbjBMckNhPzNSPauGrL1hyowPavalD96zEyrAuPL26eBzT5EFlOBCe7xjc_Sn6qZVW1j-LKJmHfKLUaaqPJIL43M0KZuOxmzuI1zb2Agf9OPI17sEYCAB6vFK5sd0EiWxlklK--k53Vg7TKBIXJ6xc-O5g
""", refreshToken: "")
    subject.send(currentToken)
  }
  
  public func tokenSubject() -> CurrentValueSubject<AuthTokenResponse, Never> {
    return CurrentValueSubject(currentToken)
  }
  
}


//@available(iOS 14.0, *)
public final class Pyramid {
  
//  public var token: Decodable?
//  private var cancellationToken: Set<AnyCancellable>
  
  public static var prefference = Prefference()
  
  public var simulatedErrors = 3
  let backgroundQueue: DispatchQueue = DispatchQueue(label: "pyramin\(UUID.init())")
  let authenticator = Authenticator()
  
  public init() {}
  
//  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
//  private func refreshToken<D: Decodable, T: Scheduler>(
//    with api: APIConfiguration,
//    urlSession: URLSession = URLSession.shared,
//    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
//    scheduler: T,
//    class type: D.Type) -> AnyPublisher<Bool, Never> {
//           request(
//               with: api,
//               scheduler: RunLoop.main,
//               class: type
//           ).sink(receiveCompletion: { completionResponse in
//               switch completionResponse {
//               case .failure(let error):
//                   print(#line, error)
//               case .finished:
//                   break
//               }
//           }, receiveValue: { [self] tokenRes in
//            token = tokenRes
//           })
//           .store(in: &cancellationToken)
//
//           return Just(true).eraseToAnyPublisher()
//  }

//  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
//  public func request<D: Decodable, T: Scheduler>(
//    with api: APIConfiguration,
//    and refreshToken: RefreshToken,
//    urlSession: URLSession = URLSession.shared,
//    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
//    scheduler: T,
//    class type: D.Type) -> AnyPublisher<D, ErrorManager> {
//    let urlRequest = constructURL(with: api)
//    return urlSession.dataTaskPublisher(for: urlRequest)
//      .tryMap({ result in
//
//        guard let httpResponse = result.response as? HTTPURLResponse else {
//          let apiError = try jsonDecoder.decode(ErrorManager.self, from: result.data)
//          throw apiError
//        }
//
//        if !httpResponse.isSuccessful  {
//          throw ErrorManager.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
//        }
//
//        return try jsonDecoder.decode(D.self, from: result.data)
//      })
//      .receive(on: scheduler)
//      .tryCatch({ error -> AnyPublisher<D, ErrorManager> in
//        guard let apiError = error as? ErrorManager, apiError.errorDescription.contains("401") else {
//          throw error
//        }
//
//        return refreshToken.refreshToken()
//          .tryMap({ [self] success -> AnyPublisher<D, ErrorManager> in
//            print(success)
//            guard success != nil else { throw error }
//            return request(with: api, scheduler: scheduler, class: type)
//          })
//          .switchToLatest()
//          .eraseToAnyPublisher()
//      })
//      .eraseToAnyPublisher()
//  }
  
//  @available(iOS 14.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
//  public func request<D: Decodable, S: Scheduler>(
//    with api: APIConfiguration,
//    urlSession: URLSession = URLSession.shared,
//    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
//    scheduler: S,
//    class type: D.Type) -> AnyPublisher<D, HTTPError> {
//
//    let urlRequest = constructURL(with: api)
//    let tokenSubject = authenticator.tokenSubject()
//
//    return tokenSubject.flatMap({ token -> AnyPublisher<D, HTTPError> in
//      return urlSession.dataTaskPublisher(for: urlRequest)
//        .assumeHTTP()
////        .flatMap({ result -> AnyPublisher<D, HTTPError> in
////          Swift.print("flatMap")
////          if let httpResponse = result as? HTTPURLResponse, httpResponse.isTimeForRefreshToken {
////            Swift.print("Fire")
////            self.authenticator.refreshToken(using: tokenSubject)
////            return Empty().eraseToAnyPublisher()
////          }
////
////          Swift.print("shit")
////          return Just(result)
////            .setFailureType(to: HTTPError.self)
////            .eraseToAnyPublisher()
////        })
//        .retryLimit(when: { [unowned self] in
//          simulatedErrors -= 1
//          return simulatedErrors > 0
//        })
//        .responseData()
//        .decoding(D.self, decoder: jsonDecoder)
//        .catch { (error: HTTPError) -> AnyPublisher<D, HTTPError> in
//            print("Delaying for error...")
//          if error.isTimeForRefreshToken {
//            self.authenticator.refreshToken(using: tokenSubject)
//            return Empty().eraseToAnyPublisher()
//          }
//
//          if error.isRetriable {
//            return Fail(error: error)
//                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
//                .eraseToAnyPublisher()
//          } else {
//            return Fail(error: error)
//                .eraseToAnyPublisher()
//          }
//        }
//        .eraseToAnyPublisher()
//    })
//    .handleEvents(receiveOutput: { _ in
//         tokenSubject.send(completion: .finished)
//     })
//    .receive(on: scheduler)
//    .eraseToAnyPublisher()
//
//  }
  
// working without refrsh token
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  public func request<D: Decodable, S: Scheduler>(
    with api: APIConfiguration,
    urlSession: URLSession = URLSession.shared,
    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
    scheduler: S,
    class type: D.Type) -> AnyPublisher<D, HTTPError> {
    let urlRequest = constructURL(with: api)

    return urlSession.dataTaskPublisher(for: urlRequest)
      .assumeHTTP()
//      .refreshTokenIfNeeded(refreshToken)
      .print("retryLimit \(simulatedErrors)")
      .retryLimit(when: { [unowned self] in
        simulatedErrors -= 1
        return simulatedErrors > 0
      })
//      .map {
//        Just($0).setFailureType(to: HTTPError.self)
//          .delay(for: .seconds(2), scheduler: DispatchQueue.main)
//          .eraseToAnyPublisher()
//      }
//      .switchToLatest()
      .responseData()
      .decoding(D.self, decoder: jsonDecoder)
      .catch { [unowned self] (error: HTTPError) -> AnyPublisher<D, HTTPError> in

        if error.isRetriable {
          print("Delaying for error...")
          return Fail(error: error)
              .delay(for: .seconds(1), scheduler: DispatchQueue.main)
              .eraseToAnyPublisher()
        } else if error.isTimeForRefreshToken {
          print("Delaying for fetchRefreshTokenSend...")
          let bool = api.fetchRefreshToken()
          print(#line, "BOOL \(bool)" )
          simulatedErrors = bool == true ?  0 : simulatedErrors

          return Fail(error: error)
              .delay(for: .seconds(2), scheduler: DispatchQueue.main)
              .eraseToAnyPublisher()
        } else {
          print("without Delay no error ..")
          return Fail(error: error)
              .eraseToAnyPublisher()
        }
      }
      .receive(on: scheduler)
      .eraseToAnyPublisher()
  }

//  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
//  public func request<D: Decodable, S: Scheduler>(
//    with api: APIConfiguration,
//    urlSession: URLSession = URLSession.shared,
//    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
//    scheduler: S,
//    class type: D.Type) -> AnyPublisher<D, HTTPError> {
//    let urlRequest = constructURL(with: api)
//
//    return urlSession.dataTaskPublisher(for: urlRequest)
//      .assumeHTTP()
//      .retryLimit(when: { [unowned self] in
//        simulatedErrors -= 1
//        return simulatedErrors > 0
//      })
//      .responseData()
//      .decoding(D.self, decoder: jsonDecoder)
//      .mapError { error in
//          if error is HTTPError {
//              return error as! HTTPError
//          } else {
//              return HTTPError.networkError(error)
//          }
//      }
//      .catch { (error: HTTPError) -> AnyPublisher<D, HTTPError> in
//          print("Delaying for error...")
//          return Fail(error: error)
//              .delay(for: .seconds(1), scheduler: DispatchQueue.main)
//              .eraseToAnyPublisher()
//      }
//      .subscribe(on: scheduler)
//      .receive(on: scheduler)
//      .eraseToAnyPublisher()
    
    
//    return urlSession.dataTaskPublisher(for: urlRequest)
//      .assumeHTTP()
////      .refreshTokenIfNeeded(refreshToken)
//      .retryLimit(when: { [unowned self] in
//        simulatedErrors -= 1
//        return simulatedErrors > 0
//      })
//      .responseData()
//      .decoding(D.self, decoder: jsonDecoder)
//      .mapError { error in
//          if error is HTTPError {
//              return error as! HTTPError
//          } else {
//              return HTTPError.networkError(error)
//          }
//      }
//      .catch { (error: HTTPError) -> AnyPublisher<D, HTTPError> in
//          print("Delaying for error...")
//          return Fail(error: error)
//              .delay(for: .seconds(1), scheduler: DispatchQueue.main)
//              .eraseToAnyPublisher()
//      }
//      .receive(on: scheduler)
//      .eraseToAnyPublisher()
//  }
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  @discardableResult
  public func request(
    with api: APIConfiguration,
    urlSession: URLSession = URLSession.shared,
    result: @escaping VoidResultCompletion) -> URLSessionTask {
    let urlRequest = constructURL(with: api)
    let task = urlSession.dataTask(with: urlRequest) { data, response, error in
      guard error == nil else {
        let error = ErrorManager.connectionError(error!)
        
        result(.failure(error))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        let error = ErrorManager.invalidServerResponse
        result(.failure(error))
        return
      }
      
      guard httpResponse.isSuccessful else {
        let error = ErrorManager.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
        result(.failure(error))
        return
      }
      
      guard let data = data else {
        let error = ErrorManager.missingBodyData
        result(.failure(error))
        return
      }
      
      result(.success(Response(urlResponse: httpResponse, data: data)))
      
    }
    
    task.resume()
    
    return task
  }
}


extension Pyramid {
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  func constructURL(with api: APIConfiguration) -> URLRequest {
    switch api.method {
    case .get:
      return setupGetRequest(with: api)
    case .put, .patch, .post:
      return setupGeneralRequest(with: api)
    case .delete:
      return setupDeleteRequest(with: api)
    }
  }
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  func setupGetRequest(with api: APIConfiguration) -> URLRequest {
    let url = api.pathAppendedURL
    switch api.dataType {
    case .requestParameters(let parameters, _):
      let url = url.generateUrlWithQuery(with: parameters)
      var request = URLRequest(url: url)
      request.setupRequest(with: api)
      return request
    default:
      var request = URLRequest(url: url)
      request.timeoutInterval = 10.0
      request.setupRequest(with: api)
      return request
    }
  }
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  func setupGeneralRequest(with api: APIConfiguration) -> URLRequest {
    let url = api.pathAppendedURL
    var request = URLRequest(url: url)
    request.setupRequest(with: api)
    switch api.dataType {
    case .requestParameters(let parameters, _):
      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
      return request
    case .requestData(let data):
      request.httpBody = data
      return request
    case .requestWithEncodable(let encodable):
      //request.httpBody = try? JSONEncoder().encode(encodable)
      
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      request.httpBody = try? encoder.encode(encodable)
      
      return request
    default:
      return request
    }
  }
  
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
  func setupDeleteRequest(with api: APIConfiguration) -> URLRequest {
    let url = api.pathAppendedURL
    switch api.dataType {
    case .requestParameters(let parameters, _):
      var request = URLRequest(url: url)
      request.setupRequest(with: api)
      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
      return request
    case .requestData(let data):
      var request = URLRequest(url: url)
      request.setupRequest(with: api)
      request.httpBody = data
      return request
    case .requestWithEncodable(let encodable):
      var request = URLRequest(url: url)
      request.setupRequest(with: api)
      request.httpBody = try? JSONSerialization.data(withJSONObject: encodable, options: .prettyPrinted)
      return request
    default:
      var request = URLRequest(url: url)
      request.httpMethod = api.method.rawValue
      return request
    }
  }
}
