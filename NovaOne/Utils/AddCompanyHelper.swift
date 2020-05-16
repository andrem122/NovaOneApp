//
//  AddCompanyTableViewUtils.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/15/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
struct AddCompanyHelper {
    // A collection of useful functions used for add company table views
    
    static func optionIsSelected(options: [EnableOption]) -> Bool {
        // Checks if at least one option is selected in the [EnableOption] array
        for option in options {
            if option.selected == true {
                return true
            }
        }
        
        return false
    }
    
    static func getSelectedOptions(options: [EnableOption]) -> String {
        // Gets all EnableOption items that have selected equal to true and makes it into a string of numbers
        var selectedString = String()
        let count = options.count
        for (index, option) in options.enumerated() {
            if option.selected == true && index != count - 1 {
                selectedString += String(index) + ","
            } else if option.selected == true && index == count - 1 {
                selectedString += String(index)
            }
        }
        
        return selectedString
    }
}
