//
//  Company+CoreDataProperties.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/9/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var address: String?
    @NSManaged public var created: Date?
    @NSManaged public var daysOfTheWeekEnabled: String?
    @NSManaged public var email: String?
    @NSManaged public var hoursOfTheDayEnabled: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var shortenedAddress: String?
    @NSManaged public var city: String?
    @NSManaged public var customerUserId: Int32
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
    @NSManaged public var customer: Customer?
    
    // MARK: Methods
    func addCompany(address: String,
                    created: Date,
                    daysOfTheWeekEnabled: String,
                    email: String,
                    hoursOfTheDayEnabled: String,
                    id: Int32,
                    name: String,
                    phoneNumber: String,
                    shortenedAddress: String,
                    city: String,
                    customerUserId: Int32,
                    state: String,
                    zip: String,
                    customer: Customer) {
        
        self.address = address
        self.created = created
        self.daysOfTheWeekEnabled = daysOfTheWeekEnabled
        self.email = email
        self.hoursOfTheDayEnabled = hoursOfTheDayEnabled
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.shortenedAddress = shortenedAddress
        self.city = city
        self.customerUserId = customerUserId
        self.state = state
        self.zip = zip
        self.customer = customer
    }
    
}
