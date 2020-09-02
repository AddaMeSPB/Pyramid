import Foundation
#if canImport(Combine)
import Combine
#endif

public final class Pyramid {
    public init() {}
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    public func refreshToken() -> AnyPublisher<Bool, Never> {
        // normally you'd have your refresh logic here
        print(refreshToken)
        return Just(false).eraseToAnyPublisher()
    }
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
   @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
   public func request<D: Decodable, T: Scheduler>(
       with api: APIConfiguration,
       urlSession: URLSession = URLSession.shared,
       jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
       scheduler: T,
       class type: D.Type) -> AnyPublisher<D, Error> {
       let urlRequest = constructURL(with: api)
       return urlSession.dataTaskPublisher(for: urlRequest)
           .tryMap({ result in

               guard let httpResponse = result.response as? HTTPURLResponse else {
                   let apiError = try jsonDecoder.decode(APIError.self, from: result.data)
                   throw apiError
               }

               if !httpResponse.isSuccessful  {
                   throw ErrorManager.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
               }

               return try jsonDecoder.decode(D.self, from: result.data)
           })
           .receive(on: scheduler)
           .tryCatch({ error -> AnyPublisher<D, Error> in
               guard let apiError = error as? ErrorManager, apiError.errorDescription.contains("401") else {
                   throw error
               }

               return self.refreshToken()
                   .tryMap({ success -> AnyPublisher<D, Error> in
                       print(success)
                       guard success != nil else { throw error }
                       return self.request(with: api, scheduler: scheduler, class: type)
                   })
                   .switchToLatest().eraseToAnyPublisher()
           })
           .eraseToAnyPublisher()
   }
}

extension Pyramid {
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
            request.setupRequest(with: api)
            return request
        }
    }

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
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try? encoder.encode(encodable)
            
            return request
        default:
            return request
        }
    }

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
