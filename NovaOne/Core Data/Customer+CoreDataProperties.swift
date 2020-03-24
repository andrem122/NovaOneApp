//
//  Customer+CoreDataProperties.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/23/20.
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

}