//
//  ErrorResponse.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

// Handles the errors from our custom PHP api script
struct ErrorResponse: Decodable, LocalizedError {
    
    let error: Int
    let reason: String
    
}

extension ErrorResponse {
    
    var errorValue: NSError {
        NSError(domain: reason, code: error, userInfo: nil)
    }
    
}
