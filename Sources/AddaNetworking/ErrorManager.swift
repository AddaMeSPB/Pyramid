//
//  ErrorManager.swift
//  
//
//  Created by Saroar Khandoker on 24.08.2020.
//

import Foundation

public enum ErrorManager : Error {
    case parameterEncodingFailed
    case invalidServerResponseWithStatusCode(statusCode: Int)
    case invalidServerResponse
    case missingBodyData
    case failedToDecodeImage
    case decodingError(Error)
    case connectionError(Error)
    case underlying(Error)
}

public extension ErrorManager {
     var errorDescription: String {
        switch self {
        case .parameterEncodingFailed:
            return "Parameter Encoding Failed!"
        case .invalidServerResponse:
            return "Failed to parse the response to HTTPResponse"
        case .connectionError(let error):
            return "Network connection seems to be offline: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding problem: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        case .invalidServerResponseWithStatusCode(let statusCode):
            return "The server response didn't fall in the given range Status Code is: \(statusCode)"
        case .missingBodyData:
            return "No body data provided from the server"
        case .failedToDecodeImage:
            return "the body doesn't contain a valid data."
        }
    }
}
