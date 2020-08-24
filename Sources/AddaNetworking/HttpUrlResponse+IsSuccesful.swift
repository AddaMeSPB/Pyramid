//
//  HttpUrlResponse+IsSuccesful.swift
//  
//
//  Created by Saroar Khandoker on 24.08.2020.
//

import Foundation

extension HTTPURLResponse {
    var isSuccessful: Bool {
        return (200..<300).contains(statusCode)
    }
}
