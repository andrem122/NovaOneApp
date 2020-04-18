//
//  Lead+CoreDataProperties.swift
//  
//
//  Created by Andre Mashraghi on 4/15/20.
//
//

import Foundation
import CoreData


extension Lead {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lead> {
        return NSFetchRequest<Lead>(entityName: "Lead")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var email: String?
    @NSManaged public var dateOfInquiry: Date?
    @NSManaged public var renterBrand: String?
    @NSManaged public var companyId: Int32
    @NSManaged public var sentTextDate: Date?
    @NSManaged public var sentEmailDate: Date?
    @NSManaged public var filledOutForm: Bool
    @NSManaged public var madeAppointment: Bool
    @NSManaged public var companyName: String?
    @NSManaged public var company: Company?
    
    func addLead(id: Int32,
                 name: String,
                 phoneNumber: String?,
                 email: String?,
                 dateOfInquiry: Date,
                 renterBrand: String,
                 companyId: Int32,
                 sentTextDate: Date?,
                 sentEmailDate: Date?,
                 filledOutForm: Bool,
                 madeAppointment: Bool,
                 companyName: String,
                 company: Company) {
        
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.dateOfInquiry = dateOfInquiry
        self.renterBrand = renterBrand
        self.companyId = companyId
        self.sentTextDate = sentTextDate
        self.sentEmailDate = sentEmailDate
        self.filledOutForm = filledOutForm
        self.madeAppointment = madeAppointment
        self.companyName = companyName
        self.company = company
        
    }

}