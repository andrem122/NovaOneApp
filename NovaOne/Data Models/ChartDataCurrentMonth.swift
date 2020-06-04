//
//  ChartDataMonth.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

struct ChartDataMonthModel: Decodable {
    // A model used to decode data relating to an objects count by day in the database

    // MARK: Properties
    var day: Int
    var count: Int
    
    // Print object's current state
    var description: String {
        
        get {
            return "Object Day: \(self.day), Object Count: \(self.count)"
        }
        
    }
    
}
