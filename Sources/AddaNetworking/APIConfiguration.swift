//
//  APIConfiguration.swift
//  
//
//  Created by Saroar Khandoker on 24.08.2020.
//

import Foundation

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
