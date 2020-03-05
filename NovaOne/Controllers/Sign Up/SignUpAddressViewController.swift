//
//  SignUpAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpAddressViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    let defaults = Defaults()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.addressTextField.becomeFirstResponder()
    }
    
    func setup() {
        
        //Disable add property button and continue button
        self.continueButton.isEnabled = false
        
        // Add disabled colors for buttons
        self.continueButton.backgroundColor = defaults.novaOneColorDisabledColor
        
    }
    
    // Toggles a button between enabled and disabled states based on text field values
    func toggle(button: UIButton, textField: UITextField, enabledColor: UIColor, disabledColor: UIColor, toggleBorderColorOnly: Bool) {
        
        guard
            let text = textField.text
        else { return }
        
        if text.isEmpty {
            
            button.isEnabled = false
            
            if toggleBorderColorOnly == true {
                button.layer.borderColor = disabledColor.cgColor
            } else {
                button.backgroundColor = disabledColor
                button.layer.borderColor = disabledColor.cgColor
            }
            
        } else {
            
            button.isEnabled = true
            
            if toggleBorderColorOnly == true {
                button.layer.borderColor = enabledColor.cgColor
            } else {
                button.backgroundColor = enabledColor
                button.layer.borderColor = enabledColor.cgColor
            }
            
        }
        
    }
    
    // MARK: Actions
    @IBAction func addressTextFieldChanged(_ sender: Any) {
        
        self.toggle(button: self.continueButton, textField: self.addressTextField, enabledColor: defaults.novaOneColor, disabledColor: defaults.novaOneColorDisabledColor, toggleBorderColorOnly: false)
    }
    
}
