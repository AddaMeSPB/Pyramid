//
//  TestEventAPIHandler.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 25.12.2020.
//

import Foundation
#if canImport(Combine)
import Combine
#endif
@testable import Pyramid

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
class TestEventAPIHandler {
  let provider = Pyramid()
  var eventSubscriber: AnyPublisher<EventResponse, HTTPError>?
  var anyCancellable: AnyCancellable?
  var isDebugEnabled: Bool = true {
    didSet {
      Pyramid.prefference.isDebuggingEnabled = isDebugEnabled
    }
  }
    
  var currentPage = 1
  var canLoadMorePages = true
  
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
extension TestEventAPIHandler {
  
  func eventList() {
    
    let query = EventQueryItem(page: "page", pageNumber: "\(currentPage)", per: "per", perSize: "10", lat: "lat", long: "long", distance: "distance", latValue: "29.873706166262373", longValue: "60.26134045287572", distanceValue: "\(250)" )
    
    eventSubscriber = provider.request(
      with: TestEventAPI.events(query),
      scheduler: RunLoop.main,
      class: EventResponse.self
    )
  }
  
  func eventListAfterRefreshToken() {
    
    let query = EventQueryItem(page: "page", pageNumber: "\(currentPage)", per: "per", perSize: "10", lat: "lat", long: "long", distance: "distance", latValue: "29.873706166262373", longValue: "60.26134045287572", distanceValue: "\(250)" )
    
    eventSubscriber = provider.request(
      with: TestEventAPI.events(query),
      scheduler: RunLoop.main,
      class: EventResponse.self
    )
  }

}
