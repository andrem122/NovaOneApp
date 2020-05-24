//
//  Appointment+CoreDataProperties.swift
//  
//
//  Created by Andre Mashraghi on 5/23/20.
//
//

import Foundation
import CoreData


extension Appointment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Appointment> {
        return NSFetchRequest<Appointment>(entityName: "Appointment")
    }

    @NSManaged public var address: String?
    @NSManaged public var companyId: Int32
    @NSManaged public var confirmed: Bool
    @NSManaged public var created: Date?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var testType: String?
    @NSManaged public var time: Date?
    @NSManaged public var timeZone: String?
    @NSManaged public var unitType: String?
    @NSManaged public var company: Company?

}
