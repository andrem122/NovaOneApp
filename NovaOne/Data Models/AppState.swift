//
//  AppState.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 8/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

class AppState: ObservableObject {
    
    static let activityViewControllerIdentifierKey = "activityViewControllerIdentifier"
    
    // Activities
    enum UserActivities: String {
        case signup = "com.novaonesoftware.signup.views"
    }
    
    // Activity Keys for user activity object
    enum UserActivityKeys: String {
        case signup = "signup.views.text"
        case signupButtonEnabled = "signup.views.buttonEnabled"
        case signupCustomerCoreDataObject = "signup.views.coreDataCustomerObject"
    }
}
