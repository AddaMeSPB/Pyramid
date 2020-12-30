//
//  Extension+HTTPURLResponse.swift
//  Pyramid
//
//  Created by Saroar Khandoker on 30.12.2020.
//

import Foundation

extension HTTPURLResponse {
  
  var isRetriable: Bool {
    return [408, 429].contains(statusCode)
  }
  
  var isSuccessful: Bool {
    return (200..<300).contains(statusCode)
  }
  
  var isTimeForRefreshToken: Bool {
    return [401, 403].contains(statusCode)
  }
  
}
