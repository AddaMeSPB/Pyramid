//
//  AuthType.swift
//  
//
//  Created by Saroar Khandoker on 25.08.2020.
//

import Foundation

public enum AuthType {
    case bearer(token: String)
    case basic(username: String, password: String)
    case none
}
