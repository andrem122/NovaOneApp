//
//  Property.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

import UIKit

struct CompanyModel: Decodable {

    // MARK: Properties
    var id: Int
    var name: String
    var address: String
    var phoneNumber: String
    var autoRespondNumber: String?
    var autoRespondText: String?
    var email: String
    var created: String
    var allowSameDayAppointments: Bool
    var daysOfTheWeekEnabled: String
    var hoursOfTheDayEnabled: String
    var city: String
    var customerUserId: Int
    var state: String
    var zip: String
    
    // Computed Properties
    var createdDate: Date {
        get {
            return DateHelper.createDate(from: self.created, format: "yyyy-MM-dd HH:mm:ss zzz")
        }

    }
    
    var shortenedAddress: String {
        get {
            let addressComponentsArray = self.address.components(separatedBy: ",")
            return addressComponentsArray[0]
        }
    }
    
    // Print object's current state
    var description: String {
        
        get {
            return "Id: \(self.id), Name: \(self.name) \(self.phoneNumber), Email: \(self.address)"
        }
        
    }
    
}
