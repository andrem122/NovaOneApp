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
    var id: Int
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
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
            guard let dateJoined = self.dateJoined else { return Date() }
            return DateHelper.createDate(from: dateJoined, format: "yyyy-MM-dd HH:mm:ss")
        }
    
    }
    
    var fullName: String {

        get {
            
            guard
                let firstName = self.firstName,
                let lastName = self.lastName
            else { return "" }
            return "\(firstName) \(lastName)"

        }

    }
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
