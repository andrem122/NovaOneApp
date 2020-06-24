//
//  Customer+CoreDataProperties.swift
//  
//
//  Created by Andre Mashraghi on 6/24/20.
//
//

import Foundation
import CoreData


extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var customerType: String?
    @NSManaged public var dateJoined: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var isPaying: Bool
    @NSManaged public var lastLogin: Date?
    @NSManaged public var lastName: String?
    @NSManaged public var password: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var username: String?
    @NSManaged public var wantsSms: Bool
    @NSManaged public var userId: Int32
    var fullName: String {
        guard
            let firstName = self.firstName,
            let lastName = self.lastName
        else { return "" }
        
        return "\(firstName) \(lastName)"
    }
    
    // MARK: Methods
    func addCustomer(customerType: String,
                     dateJoined: Date,
                     email: String,
                     firstName: String,
                     id: Int32,
                     userId: Int32,
                     isPaying: Bool,
                     lastName: String,
                     phoneNumber: String,
                     wantsSms: Bool,
                     password: String,
                     username: String,
                     lastLogin: Date,
                     companies: NSSet?) {
        
        // Adds customer obeject to CoreData
        
        self.customerType = customerType
        self.dateJoined = dateJoined
        self.email = email
        self.firstName = firstName
        self.id = id
        self.userId = userId
        self.isPaying = isPaying
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.wantsSms = wantsSms
        self.password = password
        self.username = username
        self.lastLogin = lastLogin
        
    }

}
