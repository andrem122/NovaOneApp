//
//  Company+CoreDataProperties.swift
//  
//
//  Created by Andre Mashraghi on 8/27/20.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var address: String?
    @NSManaged public var allowSameDayAppointments: Bool
    @NSManaged public var autoRespondNumber: String?
    @NSManaged public var autoRespondText: String?
    @NSManaged public var city: String?
    @NSManaged public var created: Date?
    @NSManaged public var customerUserId: Int32
    @NSManaged public var daysOfTheWeekEnabled: String?
    @NSManaged public var email: String?
    @NSManaged public var hoursOfTheDayEnabled: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var shortenedAddress: String?
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
    
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
                    autoRespondNumber: String,
                    autoRespondText: String,
                    customer: Customer,
                    allowSameDayAppointments: Bool) {
        
        self.address = address
        self.created = created
        self.allowSameDayAppointments = allowSameDayAppointments
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
        self.autoRespondText = autoRespondText
        self.autoRespondNumber = autoRespondNumber
    }


}
