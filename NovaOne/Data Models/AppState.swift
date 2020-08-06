//
//  AppState.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 8/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

class AppState: ObservableObject {
    var addObjectViewIsPresented = false
    var textFieldText = ""
}

extension AppState {
    // Activities
    static let activityTypeViewLeads = "com.novaonesoftware.leads.views"
    static let activityTypeViewSignup = "com.novaonesoftware.signup.views"
    
    static let activityAddViewKeyLeads = "leads.views.add"
    static let activitySignupKey = "signup.views.text"
}
