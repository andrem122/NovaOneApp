//
//  ChartDataMonthly.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/25/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

struct ChartDataMonthlyModel: Decodable {
    // A model used to decode data relating to an objects count by day in the database

    // MARK: Properties
    var month: String
    var year: String
    var count: Int
    
    // Print object's current state
    var description: String {
        
        get {
            return "Object Month: \(self.month), Object Year: \(self.year), Object Count: \(self.count)"
        }
        
    }
    
}
