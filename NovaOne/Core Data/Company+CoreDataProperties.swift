//
//  Company+CoreDataProperties.swift
//  
//
//  Created by Andre Mashraghi on 7/29/20.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var address: String?
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
    @NSManaged public var allowSameDayAppointments: Bool
    @NSManaged public var appointments: NSSet?
    @NSManaged public var leads: NSSet?
    
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

// MARK: Generated accessors for appointments
extension Company {

    @objc(addAppointmentsObject:)
    @NSManaged public func addToAppointments(_ value: Appointment)

    @objc(removeAppointmentsObject:)
    @NSManaged public func removeFromAppointments(_ value: Appointment)

    @objc(addAppointments:)
    @NSManaged public func addToAppointments(_ values: NSSet)

    @objc(removeAppointments:)
    @NSManaged public func removeFromAppointments(_ values: NSSet)

}

// MARK: Generated accessors for leads
extension Company {

    @objc(addLeadsObject:)
    @NSManaged public func addToLeads(_ value: Lead)

    @objc(removeLeadsObject:)
    @NSManaged public func removeFromLeads(_ value: Lead)

    @objc(addLeads:)
    @NSManaged public func addToLeads(_ values: NSSet)

    @objc(removeLeads:)
    @NSManaged public func removeFromLeads(_ values: NSSet)

}
