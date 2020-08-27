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
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpName.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpName.rawValue
        
        guard
            let firstNameText = self.firstNameTextField.text,
            let lastNameText = self.lastNameTextField.text
        else { print("could not get first name and last name text - SignUpNameViewController"); return NSUserActivity(activityType: "None") }
        
        let textFieldText = "\(firstNameText), \(lastNameText)"
        let continueButtonState = firstNameText.isEmpty || lastNameText.isEmpty ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpName.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func setup() {
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.firstNameTextField.placeholder = "First Name"
        self.lastNameTextField.placeholder = "Last Name"
        
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            let nameArray = self.restoreText?.components(separatedBy: ",")
            self.firstNameTextField.text = nameArray?[0]
            self.lastNameTextField.text = nameArray?[1]
            
            // Restore button state
            guard let continueButtonState = self.restoreContinueButtonState else { return }
            if continueButtonState == true {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            } else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            }
        } else {
            // Get data from coredata if it is available and fill in the text field if no state restoration text exists
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else {
                print("could not get coredata customer object - Sign Up Name View Controller")
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
                return
            }
            guard let firstName = coreDataCustomerObject.firstName else { print("could not get core data customer first name - Sign Up Name View Controller"); return }
            guard let lastName = coreDataCustomerObject.lastName else { print("could not get core data customer last name - Sign Up Name View Controller"); return }
            
            self.firstNameTextField.text = firstName
            self.lastNameTextField.text = lastName
            
            // Enable/Disable the continue button
            if firstName.isEmpty || lastName.isEmpty {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            } else {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            }
        }
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
            
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - Sign Up Name View Controller"); return }
            coreDataCustomerObject.firstName = firstName
            coreDataCustomerObject.lastName = lastName
            
            PersistenceService.saveContext(context: nil)
            
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
