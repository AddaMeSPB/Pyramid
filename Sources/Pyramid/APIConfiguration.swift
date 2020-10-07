//
//  APIConfiguration.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation
import Combine

public protocol APIConfiguration {
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var dataType: DataType { get }
    var authType: AuthType { get }
    var pathPrefix: String { get }
    var path: String { get }
    var contentType: ContentType? { get }
    var headers: [String: String]? { get }
}

public extension APIConfiguration {
    var pathAppendedURL: URL {
        var url = baseURL
        url.appendPathComponent(path)
        return url
    }
}

public protocol RetrierFactory {
    func create<R>(for request: R) -> Retrier where R: APIConfiguration
}

public protocol Retrier {

    /// Whether the retrier may retry requests for multiple times or if - when the request fails -
    /// the retrier is not called again. Defaults to `false`.
    var allowsMultipleRetries: Bool { get }

    /// Retries the given request that failed with the given error. Based on this information,
    /// the retrier is expected to perform any action such that the probability of the request
    /// succeeding when scheduled for the next time is increased. The function returns a future
    /// that should emit a boolean whether to actually retry the given request. When the emitted
    /// value is `true`, the request is retried immediately, otherwise, the upstream failure is
    /// propagated to the downstream subscriber immediately. As indicated by the types, the future
    /// may never fail.
    ///
    /// - Parameter request: The request that caused an error.
    /// - Parameter error: The error indiciating the reason for the failure of the request.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    func retry<R>(_ request: R, failingWith error: Error) -> Future<Bool, Never>
        where R: APIConfiguration
}

extension Retrier {
    public var allowsMultipleRetries: Bool {
        return false
    }
}
