//
//  CustomerModel.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class CustomerModel: NSObject {

    // MARK: Properties
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var primaryPhone: String?
    var address: String?
    var dateJoinedString: String?
    var dateJoined: Date {
        
        get {
            // Date string must be in the form of "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            let date = dateFormatter.date(from: dateJoinedString!)!
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            
            guard let finalDate = calendar.date(from: components) else {
                return Date()
            }
            
            return finalDate
        }
    
    }
    
    
    // Empty constructor
    override init() {
    
    }
    
    
    // MARK: Initialization
    init(id: Int, firstName: String, lastName: String, email: String, primaryPhone: String, address: String, dateJoinedString: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.primaryPhone = primaryPhone
        self.address = address
        self.dateJoinedString = dateJoinedString
    }
    
    // MARK: Methods
    static func convertDateString(dateString: String) -> Date {
        // Date string must be in the form of "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from: dateString)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        guard let finalDate = calendar.date(from: components) else {
            return Date()
        }
        
        return finalDate
        
    }
    
    
    // Print object's current state
    override var description: String {
        return "Id: \(self.id as Int?), Name: \(self.firstName as String?) \(self.lastName as String?), Email: \(self.email as String?)"
    }
    
}
