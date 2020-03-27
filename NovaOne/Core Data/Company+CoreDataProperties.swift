//
//  Company+CoreDataProperties.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/26/20.
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
    @NSManaged public var customer: Customer?

}
