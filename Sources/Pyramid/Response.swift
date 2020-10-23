//
//  Response.swift
//  Pyramid
//
//  Created by Saroar Khandoker on 23.10.2020.
//

import Foundation

public struct Response {
  public let urlResponse: HTTPURLResponse
  public let data: Data
  
  public var statusCode: Int { urlResponse.statusCode }
  public  var localizedStatusCodeDescription: String { HTTPURLResponse.localizedString(forStatusCode: statusCode) }
}
