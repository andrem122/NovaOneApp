//
//  File.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct Appointment: Decodable {

    // MARK: Properties
    var id: Int
    var name: String
    var phoneNumber: String
    var time: String
    var created: String
    var timeZone: String
    var confirmed: Bool
    var address: String
    var unitType: String
    var customerUserId: Int
    
    // Computed properties
    var timeDate: Date {
        
        get {
            // Date string must be in the form of "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            guard let date = dateFormatter.date(from: self.time) else { return Date() }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            
            guard let finalDate = calendar.date(from: components) else { return Date() }
            
            return finalDate
        }
    
    }
    
    // Print object's current state
    var description: String {
        
        get {
           return "Id: \(self.id), Name: \(self.name) \(self.phoneNumber), Email: \(self.address)"
        }
        
    }
    
}
