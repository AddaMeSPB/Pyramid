import Foundation
#if canImport(Combine)
import Combine
#endif

public typealias VoidResultCompletion = (Result<Response, ErrorManager>) -> Void

public struct Prefference {
  public var isDebuggingEnabled: Bool = false
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public final class Pyramid {
  
  public static var prefference = Prefference()
  public var simulatedErrors = 3
  
  public init() {}
  
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
      .receive(on: scheduler)
      .retryLimit(when: { [unowned self] in
        simulatedErrors -= 1
        return simulatedErrors > 0
      })
      .responseData()
      .decoding(D.self, decoder: jsonDecoder)
      .catch { [unowned self] (error: HTTPError) -> AnyPublisher<D, HTTPError> in

        if error.isTimeForRefreshToken {
          
          let bool = api.fetchRefreshToken()
          simulatedErrors = bool == true ?  0 : simulatedErrors
          return Fail(error: error)
              .delay(for: .seconds(2), scheduler: DispatchQueue.main)
              .eraseToAnyPublisher()
          
        } else if error.isRetriable {
          
          return Fail(error: error)
              .delay(for: .seconds(1), scheduler: DispatchQueue.main)
              .eraseToAnyPublisher()
          
        } else {
          
          return Fail(error: error)
              .eraseToAnyPublisher()
          
        }
      }
      .eraseToAnyPublisher()
  }
  
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
