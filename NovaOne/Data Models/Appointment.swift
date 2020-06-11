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
    var id: Int?
    var name: String
    var phoneNumber: String
    var time: String
    var created: String?
    var timeZone: String
    var confirmed: Bool
    var companyId: Int
    var unitType: String?
    var email: String?
    var dateOfBirth: String?
    var testType: String?
    var gender: String?
    var address: String?
    
    // Computed Properties
    var timeDate: Date {
        get {
            return DateHelper.createDate(from: self.time, format: "yyyy-MM-dd HH:mm:ssZ")
        }

    }
    
    var createdDate: Date {
        get {
            guard let created = self.created else { return Date() }
            return DateHelper.createDate(from: created, format: "yyyy-MM-dd HH:mm:ss zzz")
        }

    }
    
    var dateOfBirthDate: Date {
        get {
            guard let dateOfBirth = self.dateOfBirth else { return Date() }
            return DateHelper.createDate(from: dateOfBirth, format: "yyyy-MM-dd")
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
            // Split the name string into an array if it has spaces
            let nameComponentsArray = self.name.components(separatedBy: " ")
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
            let index = self.name.index(self.name.startIndex, offsetBy: 2)
            let initials = String(self.name[..<index])
            return initials.uppercased()
        }
        
    }
    
    // Print object's current state
    var description: String {
        
        get {
            guard
                let address = self.address,
                let id = self.id
            else { return "" }
            
            return "Id: \(id), Name: \(self.name) \(self.phoneNumber), Address: \(address)"
        }
        
    }
    
}
