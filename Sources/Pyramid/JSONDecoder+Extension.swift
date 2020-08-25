//
//  JSONDecoder+Extension.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
extension JSONDecoder {
    public static let ISO8601JSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
