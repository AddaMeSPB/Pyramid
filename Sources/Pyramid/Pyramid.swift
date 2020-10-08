import Foundation
#if canImport(Combine)
import Combine
#endif

public struct APIError: Decodable, Error {
    public let statusCode: Int
}

protocol RequiresAuth {
    var header: [String: String] { get }
}

public final class Pyramid {
    public init() {}
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
        class type: D.Type) -> AnyPublisher<D, ErrorManager> {
        let urlRequest = constructURL(with: api)
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryCatch { error -> URLSession.DataTaskPublisher in
                guard error.networkUnavailableReason == .constrained else {
                    throw ErrorManager.connectionError(error)
                }
                return urlSession.dataTaskPublisher(for: urlRequest)
            }
            .receive(on: scheduler)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ErrorManager.invalidServerResponse
                }
                if !httpResponse.isSuccessful  {
                    throw ErrorManager.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: type.self, decoder: jsonDecoder).mapError { error in
                if let error = error as? ErrorManager {
                    return error
                } else {
                    return ErrorManager.decodingError(error)
                }
            }.eraseToAnyPublisher()
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
            encoder.dateEncodingStrategy = .iso8601
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
