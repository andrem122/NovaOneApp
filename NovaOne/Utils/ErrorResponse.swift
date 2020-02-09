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
    
    let reason: String
    var errorDescription: String? { return reason }
    
}
