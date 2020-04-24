//
//  ObjectCount.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/21/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

struct ObjectCountModel: Decodable {
    // A model used to decode data relating to an objects count and name in the database

    // MARK: Properties
    var name: String
    var count: Int
    
    // Print object's current state
    var description: String {
        
        get {
            return "Object Name: \(self.name), Object Count: \(self.count)"
        }
        
    }
    
}
