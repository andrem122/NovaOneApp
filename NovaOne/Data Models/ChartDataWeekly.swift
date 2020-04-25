//
//  File.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

struct ChartDataWeeklyModel: Decodable {
    // A model used to decode data relating to an objects count by day in the database

    // MARK: Properties
    var date: String
    var count: Int
    var dateDate: Date {
        return DateHelper.createDate(from: self.date, format: "yyyy-MM-dd")
    }
    
    // Print object's current state
    var description: String {
        
        get {
            return "Object Date: \(self.date), Object Count: \(self.count)"
        }
        
    }
    
}
