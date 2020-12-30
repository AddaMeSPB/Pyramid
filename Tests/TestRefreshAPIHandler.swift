//
//  TestRefreshAPIHandler.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 30.12.2020.
//

import Foundation
#if canImport(Combine)
import Combine
#endif
@testable import Pyramid

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
class TestRefreshAPIHandler {
  let provider = Pyramid()
  var refreshSubscriber: AnyPublisher<AuthTokenResponse, HTTPError>?
  var anyCancellable: AnyCancellable?
  var isDebugEnabled: Bool = true {
    didSet {
      Pyramid.prefference.isDebuggingEnabled = isDebugEnabled
    }
  }
  
}

extension TestRefreshAPIHandler {
  func refreshToken() {
    
    let referehTokenInput = RefreshTokenInput(refreshToken: refreshTokenForInvalidToken)
    anyCancellable = provider.request(
      with: RefreshTokenAPI.refresh(token: referehTokenInput),
      scheduler: RunLoop.main,
      class: AuthTokenResponse.self
    )
    .sink(receiveCompletion: { completionResponse in
      switch completionResponse {
      case .failure(let error):
        print(#line, error)
      case .finished:
        break
      }
    }, receiveValue: { [unowned self] res in
      print(#line, res)
      DispatchQueue.main.async {
        refreshTokenForInvalidToken = res.refreshToken
        invalidAccessToken = res.accessToken
      }
    })
    
  }
  
}
