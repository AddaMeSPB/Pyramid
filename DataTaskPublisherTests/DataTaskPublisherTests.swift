//
//  DataTaskPublisherTests.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 25.12.2020.
//

import XCTest
import Combine
@testable import Pyramid

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)

final class DataTaskPublisherTests: XCTestCase {
  
  var eventTestClass: TestEventAPIHandler!
  var refrestTokenClass: TestRefreshAPIHandler!
  
  override func setUp() {
    super.setUp()
    eventTestClass = TestEventAPIHandler()
    refrestTokenClass = TestRefreshAPIHandler()
    eventTestClass.isDebugEnabled = false
  }
  
  override func tearDown() {
    eventTestClass = nil
    super.tearDown()
  }
}

extension DataTaskPublisherTests {
  func testEventList() {
    let exp = expectation(description: "List All Events")
    eventTestClass.eventList()
    guard let testSubscriber = eventTestClass.eventSubscriber else {
      return assertionFailure()
    }
    
    eventTestClass.anyCancellable = testSubscriber
      .tryCatch { [unowned self] error -> AnyPublisher<EventResponse, HTTPError> in
        if error.isRetriable {
            print("RETRYING...")
            return testSubscriber.retry(2).eraseToAnyPublisher()
        } else if error.isTimeForRefreshToken {
          print("RETRYING...")
//          refrestTokenClass.refreshToken()
          return testSubscriber.eraseToAnyPublisher()
        } else {
            throw error
        }
       
      }
      .sink(receiveCompletion: { completionResponse in
      switch completionResponse {
      case .failure(let error):
        
        XCTFail(error.localizedDescription)
      case .finished:
        break
      }
    }, receiveValue: { data in
      print(#line, data.items.count)
      exp.fulfill()
    })
    
    wait(for: [exp], timeout: 15)
  }
  
  func testEventListAfterRefreshToken()  {
    
  }
}
