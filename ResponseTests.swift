//
//  ResponseTests.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 30.12.2020.
//

import XCTest
@testable import Pyramid

final class ResponseTests: XCTestCase { }


extension ResponseTests {

  func testResponse() {
    let testURL = URL(string: "https://addame.com")
    let testStatusCode = 200
    let testHeaderFields: [String: String] = ["Test": "Value"]
    let testData = "Some Test Data".data(using: .utf8)!
    
    let response = Response(
      urlResponse: HTTPURLResponse(
        url: testURL!,
        statusCode: testStatusCode,
        httpVersion: nil,
        headerFields: testHeaderFields
      )!,
        data: testData
    )
  
  
    XCTAssertEqual(response.statusCode, testStatusCode)
    XCTAssertEqual(response.data, testData)
    XCTAssertEqual(response.localizedStatusCodeDescription, HTTPURLResponse.localizedString(forStatusCode: testStatusCode))
  }

}
