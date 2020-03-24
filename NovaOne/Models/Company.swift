//
//  Property.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

import UIKit

struct Company: Decodable {

    // MARK: Properties
    var id: Int
    var name: String?
    var address: String?
    var phoneNumber: String?
    var email: String?
    var created: String?
    var daysOfTheWeekEnabled: String?
    var hoursOfTheDayEnabled: String?
    
    // Computed Properties
    var createdDate: Date {
        get {
            guard let created = self.created else { return Date() }
            return DateHelper.createDate(from: created, format: "yyyy-MM-dd HH:mm:ss zzz")
        }

    }
    
    var shortenedAddress: String {
        get {
            guard let address = self.address else { return "" }
            let addressComponentsArray = address.components(separatedBy: ",")
            return addressComponentsArray[0]
        }
    }
    
    // Print object's current state
    var description: String {
        
        get {
            let id = self.id
            guard
                let name = self.name,
                let phoneNumber = self.phoneNumber,
                let address = self.address
            else { return "" }
           return "Id: \(id), Name: \(name) \(phoneNumber), Email: \(address)"
        }
        
    }
    
}
