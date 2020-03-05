//
//  UIHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UIHelper {
    
    // Toggles a button between enabled and disabled states based on text field values
    static func toggle(button: UIButton, textField: UITextField, enabledColor: UIColor, disabledColor: UIColor, borderedButton: Bool?) {
        
        guard
            let text = textField.text
        else { return }
        
        if text.isEmpty {
            
            button.isEnabled = false
            
            if borderedButton == true {
                button.layer.borderColor = disabledColor.cgColor
            } else {
                button.backgroundColor = disabledColor
                button.layer.borderColor = disabledColor.cgColor
            }
            
        } else {
            
            button.isEnabled = true
            
            if borderedButton == true {
                button.layer.borderColor = enabledColor.cgColor
            } else {
                button.backgroundColor = enabledColor
                button.layer.borderColor = enabledColor.cgColor
            }
            
        }
        
    }
    
    // Disables a button
    static func disable(button: UIButton, disabledColor: UIColor, borderedButton: Bool?) {
        
        button.isEnabled = false
        if borderedButton == true {
            button.layer.borderColor = disabledColor.cgColor
        } else {
            button.backgroundColor = disabledColor
        }
        
    }
    
}
