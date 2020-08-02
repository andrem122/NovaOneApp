//
//  CustomerModel.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//
import UIKit

struct CustomerModel: Decodable {

    // MARK: Properties
    var id: Int
    var userId: Int
    var password: String
    var lastLogin: String
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var dateJoined: String
    var isPaying: Bool
    var wantsSms: Bool
    var wantsEmailNotifications: Bool
    var phoneNumber: String
    var customerType: String
    
    // Computed properties
    var dateJoinedDate: Date {
        
        get {
            return DateHelper.createDate(from: self.dateJoined, format: "yyyy-MM-dd HH:mm:ss")
        }
    
    }
    
    var lastLoginDate: Date {
        
        get {
            return DateHelper.createDate(from: self.lastLogin, format: "yyyy-MM-dd HH:mm:ss")
        }
    
    }
    
    var fullName: String {

        get {
            return "\(self.firstName) \(self.lastName)"
        }

    }
    
    // Print object's current state
    var description: String {

        get {
           return "Id: \(self.id), Name: \(self.firstName) \(self.lastName), Email: \(self.email)"
        }

    }
    
}
