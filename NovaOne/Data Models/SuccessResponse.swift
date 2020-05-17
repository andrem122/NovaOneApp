//
//  SuccessResponse.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/16/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

// Handles the errors from our custom PHP api script
struct SuccessResponse: Decodable {
    
    let success: Int
    let reason: String
    
}

