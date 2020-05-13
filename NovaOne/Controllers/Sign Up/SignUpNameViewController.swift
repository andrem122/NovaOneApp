//
//  SignUpNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpNameViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var firstNameTextField: NovaOneTextField!
    @IBOutlet weak var lastNameTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // MARK: Methods
    func setup() {
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.firstNameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func firstNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) { [weak self] () -> Bool in
            
            // Unwrap text from text fields
            guard
                let firstName = self?.firstNameTextField.text,
                let lastName = self?.lastNameTextField.text
            else { return false }
            
            // If first name and last name text values are empty, return false so that the button will be disabled
            if firstName.isEmpty || lastName.isEmpty {
                return false
            }
            
            // First and last name text values are NOT empty.
            // Return true to enable button
            return true
        }
    }
    
    
    @IBAction func lastNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) { [weak self] () -> Bool in
            
            // Unwrap text from text fields
            guard
                let firstName = self?.firstNameTextField.text,
                let lastName = self?.lastNameTextField.text
            else { return false }
            
            // If first name and last name text values are empty, return false so that the button will be disabled
            if firstName.isEmpty || lastName.isEmpty {
                return false
            }
            
            // First and last name text values are NOT empty.
            // Return true to enable button
            return true
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard
            let firstName = self.firstNameTextField.text,
            let lastName = self.lastNameTextField.text
        else { return }
        
        if firstName.trim().isAlphabetical && lastName.trim().isAlphabetical {
            guard
                let signUpPhoneViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpPhone.rawValue) as? SignUpPhoneViewController
            else { return }

            // Pass customer object
            self.customer?.firstName = firstName
            self.customer?.lastName = lastName
            signUpPhoneViewController.customer = self.customer
            
            // Navigate to next view controller
            self.navigationController?.pushViewController(signUpPhoneViewController, animated: true)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Name", body: "Please enter a name with only alphabetic characters.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension SignUpNameViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        } else {
            self.continueButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}
