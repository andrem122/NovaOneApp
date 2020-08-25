//
//  ObjectDetail.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/20/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

enum TitleItem: String {
    // An enumeration containing all titles for object detail items in each detail view controller
    case name = "Name"
    case address = "Address"
    case phoneNumber = "Phone Number"
    case email = "Email"
    case appointmentLink = "Appointment Link"
    case showingDays = "Showing Days"
    case showingHours = "Showing Hours"
    case allowSameDayAppointments = "Same Day Appointments"
    case autoRespondNumber = "Auto Respond Number"
    case autoRespondText = "Auto Respond Text"
    case appointmentTime = "Time"
    case confirmed = "Confirmed"
    case unitType = "Unit Type"
    case dateOfBirth = "Date Of Birth"
    case testType = "Test Type"
    case gender = "Gender"
    case contacted = "Contacted"
    case companyName = "Company"
    case dateOfInquiry = "Date Of Inquiry"
    case renterBrand = "Renter Brand"
    case sentTextDate = "Sent Text Date"
    case sentEmailDate = "Sent Email Date"
    case city = "City"
    case zip = "Zip"
}

class ObjectDetailItem: NSObject {
    // A model class to represent the data for the items for each ObjectDetailTableViewCell
    
    let title: String
    let titleValue: String
    let titleItem: TitleItem
    
    init(titleValue: String, titleItem: TitleItem) {
        self.title = titleItem.rawValue
        self.titleValue = titleValue
        self.titleItem = titleItem
    }
}
