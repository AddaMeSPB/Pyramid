//
//  APIConfiguration.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation
import Combine

public protocol APIConfiguration: RequiresAuth {
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var dataType: DataType { get }
    var pathPrefix: String { get }
    var path: String { get }
    var contentType: ContentType? { get }
    func fetchRefreshToken() -> Bool
}

public protocol APIOperation {}
extension APIOperation where Self: APIConfiguration & RequiresAuth {}
// extension Array where Element: Comparable {}

public extension APIConfiguration {
    var pathAppendedURL: URL {
        var url = baseURL
        url.appendPathComponent(path)
        return url
    }
}

public protocol RequiresAuth {
  var headers: [String: String]? { get }
  var authType: AuthType { get }
}
