//
//  Response.swift
//  Pyramid
//
//  Created by Saroar Khandoker on 23.10.2020.
//

import Foundation

public struct Response {
  let urlResponse: HTTPURLResponse
  let data: Data
  
  var statusCode: Int { urlResponse.statusCode }
  var localizedStatusCodeDescription: String { HTTPURLResponse.localizedString(forStatusCode: statusCode) }
}
