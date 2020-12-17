//
//  URLRequest+setupRequest.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation

internal extension URLRequest {
    private var headerField: String { "Authorization" }
    private var contentTypeHeader: String { "Content-Type" }

  mutating func setupRequest(with api: APIConfiguration, requiresAuth: RequiresAuth? = nil) {
        let contentTypeHeaderName = contentTypeHeader
        allHTTPHeaderFields = requiresAuth?.headers
        setValue(api.contentType?.rawValue, forHTTPHeaderField: contentTypeHeaderName)
        setupAuthorization(with: requiresAuth?.authType)
        httpMethod = api.method.rawValue
    }

    private mutating func setupAuthorization(with authType: AuthType? = nil ) {
        switch authType {
        case .basic(let username, let password):
            let loginString = String(format: "%@:%@", username, password)
            guard let data = loginString.data(using: .utf8) else { return }
            setValue("Basic \(data.base64EncodedString())", forHTTPHeaderField: headerField)
        case .bearer(let token):
            setValue("Bearer \(token)", forHTTPHeaderField: headerField)
        case .some(.none): break
        case .none: break
        }
    }
}
