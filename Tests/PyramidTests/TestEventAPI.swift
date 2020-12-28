//
//  EventAPITest.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 25.12.2020.
//

import Foundation
@testable import Pyramid


struct EventQueryItem: Codable {
  var page: String
  var pageNumber: String
  var per: String
  var perSize: String
  var lat: String
  var long: String
  var distance: String
  var latValue: String
  var longValue: String
  var distanceValue: String
}

enum TestEventAPI {
    case events(_ query: EventQueryItem)
}


extension TestEventAPI: APIConfiguration, RequiresAuth {

  // APIOperation

  var baseURL: URL { URL(string: "http://192.168.1.20:8080/v1")! }
    
    var pathPrefix: String {
        return "/events"
    }

    var path: String {
        return pathPrefix + {
            switch self {
            case .events: return String.empty
            }
        }()
    }
    
    var method: HTTPMethod {
        switch self {
          case .events: return .get
        }
    }
    
    var dataType: DataType {
        switch self {
        case .events(let eventQuery):
             return .requestParameters(parameters: [
              eventQuery.page: eventQuery.pageNumber,
              eventQuery.per: eventQuery.perSize,
              eventQuery.lat: eventQuery.latValue,
              eventQuery.long: eventQuery.longValue,
              eventQuery.distance: eventQuery.distanceValue,
             ])
        }
    }

    var contentType: ContentType? {
        switch self {
        case .events:
            return .applicationJson
        }
    }
    
}

extension String {
  static var empty: String { return "" }
}
