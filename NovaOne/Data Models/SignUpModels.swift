//
//  SignUpModels.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

struct CustomerSignUpModel: Decodable {
    // The data model used for customers that are signing up in the app
    // MARK: Properties
    var email: String
    var password: String
    var phoneNumber: String
    var firstName: String
    var lastName: String
    var customerType: String
}

struct CompanySignUpModel: Decodable {
    // The data model used for storing a customer's company information during the signup process
    // MARK: Properties
    var address: String
    var name: String
    var phoneNumber: String
    var email: String
    var city: String
    var state: String
    var zip: String
}
