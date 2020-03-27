//
//  File.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct AppointmentModel: Decodable {

    // MARK: Properties
    var id: Int
    var name: String?
    var phoneNumber: String?
    var address: String?
    var time: String?
    var created: String?
    var timeZone: String?
    var confirmed: Bool?
    
    // Computed Properties
    var timeDate: Date {
        get {
            guard let time = self.time else { return Date() }
            return DateHelper.createDate(from: time, format: "yyyy-MM-dd HH:mm:ssZ")
        }

    }
    
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
    
    // Returns the initials of the first and last name of the person making the appointment
    // or the first two letters of the first name if there is no last name
    var initials: String {
        
        get {
            guard let name = self.name else { return "" }
            
            // Split the name string into an array if it has spaces
            let nameComponentsArray = name.components(separatedBy: " ")
            // If our array has a count greater than one, we have multiple names
            // get the first character of the first and second element
            // in the array
            if nameComponentsArray.count > 1 && nameComponentsArray[1] != "" {
                let firstName = nameComponentsArray[0]
                let secondName = nameComponentsArray[1]
                
                let firstNameInitial = firstName[firstName.startIndex]
                let secondNameInitial = secondName[secondName.startIndex]
                
                return "\(firstNameInitial)\(secondNameInitial)".uppercased()
            }
            
            // Return the first two characters of the string if only one name is given
            let index = name.index(name.startIndex, offsetBy: 2)
            let initials = String(name[..<index])
            return initials.uppercased()
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
