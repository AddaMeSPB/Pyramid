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
}

public extension APIConfiguration {
    var pathAppendedURL: URL {
        var url = baseURL
        url.appendPathComponent(path)
        return url
    }
}

