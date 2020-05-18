//
//  SignUpPropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCompanyPhoneViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var propertyPhoneTextField: NovaOneTextField!
    
    // MARK: Methods
    func setup() {
        self.propertyPhoneTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        // Make text field become first responder
        self.propertyPhoneTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all) // Reset orientation
    }
    
    // MARK: Actions
    @IBAction func propertyPhoneTextFieldChanged(_ sender: Any) {
        
        UIHelper.toggle(button: self.continueButton, textField: self.propertyPhoneTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
        
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard
            let addCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue) as? AddCompanyDaysEnabledViewController,
            let phoneNumber = self.propertyPhoneTextField.text
        else { return }
        
        let unformattedPhoneNumber = "%2B1" + phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        self.company?.phoneNumber = unformattedPhoneNumber
        addCompanyDaysEnabledViewController.customer = self.customer
        addCompanyDaysEnabledViewController.company = self.company
        addCompanyDaysEnabledViewController.userIsSigningUp = true // Indicates that the user is new and signing up and not an existing user adding a company
        
        self.navigationController?.pushViewController(addCompanyDaysEnabledViewController, animated: true)
    }
    
}

extension SignUpCompanyPhoneViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var phoneNumber = textField.text else { return false }
        UIHelper.toggle(button: self.continueButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) {() -> Bool in
            
            let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
            
            // Add one to the unformatted phone number count because textfield.text
            // does NOT include the last typed character into the textfield
            if phoneNumber.isEmpty || string.isEmpty || unformattedPhoneNumber.count + 1 < 10 {
                return false
            }
            
            // Number entered is 10 digits and is not empty, so enable continue button
            return true
        }

        phoneNumber.append(string)
        if range.length == 1 {
            textField.text = InputFormatters.format(phoneNumber: phoneNumber, shouldRemoveLastDigit: true)
        } else {
            textField.text = InputFormatters.format(phoneNumber: phoneNumber)
        }
        
        return false
    }
}
