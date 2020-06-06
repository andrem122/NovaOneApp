//
//  EnableOptionHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/15/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
struct EnableOptionHelper {
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
        let selectedOptions = options.filter { (option) -> Bool in
            option.selected == true
        }
        
        var selectedString = String()
        for (index, option) in options.enumerated() {
            if option.selected == true && option.id != selectedOptions.last?.id {
                selectedString += String(index) + ","
            } else if option.selected == true {
                selectedString += String(index)
            }
        }
        
        return selectedString
    }
}
