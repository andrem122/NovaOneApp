//
//  Leads.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct Lead: Decodable {
    
    /*
     l.id,
     l.name,
     l.phone,
     l.email,
     l.date_of_inquiry as \"dateOfInquiry\",
     l.renter_brand as \"renterBrand\",
     l.sent_text_date as \"sentTextDate\",
     l.sent_email_date as \"sentEmailDate\",
     l.filled_out_form as \"filledOutForm\",
     l.made_appointment as \"madeAppointment\",
     p.address
     */

    // MARK: Properties
    var id: Int
    var name: String?
    var phone: String?
    var email: String?
    var dateOfInquiry: String?
    var renterBrand: String?
    var sentTextDate: String?
    var sentEmailDate: String?
    var filledOutForm: Bool?
    var madeAppointment: Bool?
    var address: String?
    
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
                let phoneNumber = self.phone,
                let address = self.address
            else { return "" }
           return "Id: \(id), Name: \(name) \(phoneNumber), Email: \(address)"
        }
        
    }
    
    // MARK: Methods
    func date(from string: String) -> Date {
        
        // Date string must be in the form of "yyyy-MM-dd HH:mm:ssZ"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        guard let date = dateFormatter.date(from: string) else { return Date() }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        guard let finalDate = calendar.date(from: components) else { return Date() }
        
        return finalDate
        
    }
    
}
