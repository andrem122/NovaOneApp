//
//  Leads.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct LeadModel: Decodable {

    // MARK: Properties
    var id: Int
    var name: String
    var phoneNumber: String?
    var email: String?
    var dateOfInquiry: String
    var renterBrand: String
    var companyId: Int
    var sentTextDate: String?
    var sentEmailDate: String?
    var filledOutForm: Bool
    var madeAppointment: Bool
    var companyName: String
    
    var dateOfInquiryDate: Date {
        get {
            return DateHelper.createDate(from: self.dateOfInquiry, format: "yyyy-MM-dd HH:mm:ssZ")
        }
    }
    
    var sentTextDateDate: Date {
        get {
            guard let sentTextDate = self.sentTextDate else { return Date() }
            return DateHelper.createDate(from: sentTextDate, format: "yyyy-MM-dd HH:mm:ssZ")
        }
    }
    
    var sentEmailDateDate: Date {
        get {
            guard let sentEmailDate = self.sentEmailDate else { return Date() }
            return DateHelper.createDate(from: sentEmailDate, format: "yyyy-MM-dd HH:mm:ssZ")
        }
    }
    
    // Print object's current state
    var description: String {
        
        get {
            let id = self.id
            guard
                let phoneNumber = self.phoneNumber,
                let email = self.email
            else { return "" }
            return "Id: \(id), Name: \(self.name) \(phoneNumber), Email: \(email)"
        }
        
    }
    
}
