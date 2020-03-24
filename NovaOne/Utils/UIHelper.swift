//
//  UIHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

// A class of commonly used functions used for interacting with the user interface
class UIHelper {
    
    // Toggles a button between enabled and disabled states based on text field values
    static func toggle(button: UIButton, textFields: [UITextField], enabledColor: UIColor, disabledColor: UIColor, borderedButton: Bool?, closure: (([UITextField]) -> Bool)?) {
        
        // If we decide to use the closure (more than one text field we want to check the value of before disabling the button)
        if let unwrappedClosure = closure {
            
            if unwrappedClosure(textFields) {
                
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
            
        } else { // One text field we are checking the value of to disable the button
            
            guard
                let text = textFields[0].text
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
    
    // Gets a view controller by a string identifier
    static func getViewController(currentViewController: UIViewController, by identifier: String) -> UIViewController {
        guard let viewController = currentViewController.storyboard?.instantiateViewController(identifier: identifier) else { return UIViewController() }
        return viewController
    }
    
}
