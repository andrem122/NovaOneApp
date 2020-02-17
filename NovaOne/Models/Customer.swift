//
//  CustomerModel.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct CustomerModel: Decodable {

    // MARK: Properties
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var customerPhone: String?
    var dateJoined: String?
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
    var dateJoinedDate: Date {
        
        get {
            // Date string must be in the form of "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            guard let dateJoined = self.dateJoined else { return Date() }
            guard let date = dateFormatter.date(from: dateJoined) else { return Date() }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            
            guard let finalDate = calendar.date(from: components) else { return Date() }
            
            return finalDate
        }
    
    }
    
//    var fullName: String? {
//
//        get { return "\(self.firstName) \(self.lastName)" }
//
//    }
//    
//    // Print object's current state
//    var description: String {
//
//        get {
//           return "Id: \(self.id), Name: \(self.firstName) \(self.lastName), Email: \(self.email)"
//        }
//
//    }
    
}
