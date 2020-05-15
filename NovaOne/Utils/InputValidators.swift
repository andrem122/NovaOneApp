//
//  InputValidators.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/15/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

struct InputValidators {
    static func isValidEmail(email: String) -> Bool {
        // Checks if email is valid
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
