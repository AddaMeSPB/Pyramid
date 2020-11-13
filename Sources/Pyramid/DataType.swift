//
//  DataType.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation

public struct AnyEncodable: Encodable {
    public let encodable: Encodable

    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    public func encode(to encoder: Encoder) throws {
      do {
          try self.encodable.encode(to: encoder)
      } catch {
          print(error)
      }
    }
}

public enum DataType {
    case requestPlain
    case requestData(data: Data)
    case requestParameters(parameters: [String: Any], encoding: JSONEncoder = JSONEncoder())
    case requestWithEncodable(encodable: AnyEncodable)
}
