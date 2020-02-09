//
//  CustomerModel.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class CustomerModel: NSObject, Decodable {

    // MARK: Properties
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var customerPhone: String?
    var dateJoinedString: String?
    var isPaying: Bool?
    var wantsSms: Bool?
    var propertyId: Int?
    var propertyName: String?
    var propertyAddress: String?
    var propertyPhone: String?
    var propertyEmail: String?
    var daysOfTheWeekEnabled: String?
    var hoursOfTheDayEnabled: String?
    
    // Computed properties
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
    
    var fullName: String? {
        
        get {
            
            guard
                let firstName = self.firstName,
                let lastName = self.lastName
            else { return nil }
            
            return "\(firstName) \(lastName)"
            
        }
        
    }
    
    
    // Empty constructor
    override init() {
    
    }
    
    
    // MARK: Initialization
    init(
        id: Int,
        firstName: String,
        lastName: String,
        email: String,
        customerPhone: String,
        dateJoinedString: String,
        isPaying: Bool,
        wantsSms: Bool,
        propertyId: Int,
        propertyName: String,
        propertyAddress: String,
        propertyPhone: String,
        propertyEmail: String,
        daysOfTheWeekEnabled: String,
        hoursOfTheDayEnabled: String
    ) {
        
        // Set properties
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.customerPhone = customerPhone
        self.dateJoinedString = dateJoinedString
        self.isPaying = isPaying
        self.wantsSms = wantsSms
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.propertyAddress = propertyAddress
        self.propertyPhone = propertyPhone
        self.propertyEmail = propertyEmail
        self.daysOfTheWeekEnabled = daysOfTheWeekEnabled
        self.hoursOfTheDayEnabled = hoursOfTheDayEnabled
        
    }
    
    // MARK: Methods
    
    
    // Print object's current state
    var customerDescription: String? {
        guard
            let id = self.id,
            let firstName = self.firstName,
            let lastName = self.lastName,
            let email = self.email
        else { return nil }
        
        return "Id: \(id), Name: \(firstName) \(lastName), Email: \(email)"
        
    }
    
}
