//
//  Customer+CoreDataProperties.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/26/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//
//

import Foundation
import CoreData


extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var companyAddress: String?
    @NSManaged public var companyEmail: String?
    @NSManaged public var companyId: Int32
    @NSManaged public var companyName: String?
    @NSManaged public var companyPhone: String?
    @NSManaged public var customerType: String?
    @NSManaged public var dateJoined: Date?
    @NSManaged public var daysOfTheWeekEnabled: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var hoursOfTheDayEnabled: String?
    @NSManaged public var id: Int32
    @NSManaged public var isPaying: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var wantsSms: Bool
    @NSManaged public var companies: NSSet?
    
    // MARK: Methods
    func addCustomer(companyAddress: String,
                     companyEmail: String,
                     companyId: Int32,
                     companyName: String,
                     companyPhone: String,
                     customerType: String,
                     dateJoined: Date,
                     daysOfTheWeekEnabled: String,
                     email: String,
                     firstName: String,
                     hoursOfTheDayEnabled: String,
                     id: Int32,
                     isPaying: Bool,
                     lastName: String,
                     phoneNumber: String,
                     wantsSms: Bool,
                     companies: NSSet?) {
        // Adds customer obeject to CoreData
        self.companyAddress = companyAddress
        self.companyEmail = companyEmail
        self.companyId = companyId
        self.companyName = companyName
        self.companyPhone = companyPhone
        self.customerType = customerType
        self.dateJoined = dateJoined
        self.daysOfTheWeekEnabled = daysOfTheWeekEnabled
        self.email = email
        self.firstName = firstName
        self.hoursOfTheDayEnabled = hoursOfTheDayEnabled
        self.id = id
        self.isPaying = isPaying
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.wantsSms = wantsSms
        self.companies = companies
        
    }

}

// MARK: Generated accessors for companies
extension Customer {

    @objc(addCompaniesObject:)
    @NSManaged public func addToCompanies(_ value: Company)

    @objc(removeCompaniesObject:)
    @NSManaged public func removeFromCompanies(_ value: Company)

    @objc(addCompanies:)
    @NSManaged public func addToCompanies(_ values: NSSet)

    @objc(removeCompanies:)
    @NSManaged public func removeFromCompanies(_ values: NSSet)

}
