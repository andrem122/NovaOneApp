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
    var id: Int?
    var name: String
    var phoneNumber: String?
    var email: String?
    var dateOfInquiry: String
    var renterBrand: String?
    var companyId: Int
    var sentTextDate: String?
    var sentEmailDate: String?
    var filledOutForm: Bool
    var madeAppointment: Bool
    var companyName: String
    
    var dateOfInquiryDate: Date {
        get {
            return DateHelper.createDate(from: self.dateOfInquiry, format:  "yyyy-MM-dd HH:mm:ss zzz")
        }
    }
    
    var sentTextDateDate: Date? {
        get {
            guard let sentTextDate = self.sentTextDate else { return nil }
            return DateHelper.createDate(from: sentTextDate, format: "yyyy-MM-dd HH:mm:ss zzz")
        }
    }
    
    var sentEmailDateDate: Date? {
        get {
            guard let sentEmailDate = self.sentEmailDate else { return nil }
            return DateHelper.createDate(from: sentEmailDate, format: "yyyy-MM-dd HH:mm:ss zzz")
        }
    }
    
    // Print object's current state
    var description: String {
        
        get {
            guard
                let id = self.id,
                let phoneNumber = self.phoneNumber,
                let email = self.email
            else { return "" }
            return "Id: \(id), Name: \(self.name) \(phoneNumber), Email: \(email)"
        }
        
    }
    
}
