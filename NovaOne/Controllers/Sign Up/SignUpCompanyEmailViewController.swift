//
//  SignUpPropertyEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCompanyEmailViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue
        
        let textFieldText = self.emailAddressTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? true ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restore(textField: self.emailAddressTextField, continueButton: self.continueButton, coreDataEntity: Company.self) { (company) -> String in
            guard let company = company as? Company else { return "" }
            guard let email = company.email else { return "" }
            return email
        }
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailAddressTextField.becomeFirstResponder()
    }
    
    func setupTextField() {
        // General setup
        self.emailAddressTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func emailAddressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = emailAddressTextField.text else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: email) {
            guard let signUpCompanyPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue) as? SignUpCompanyPhoneViewController else { return }
            
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - Sign Up Company Email View Controller"); return }
            coreDataCompanyObject.email = email
            
            // Save to context
            PersistenceService.saveContext(context: nil)
            
            self.navigationController?.pushViewController(signUpCompanyPhoneViewController, animated: true)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension SignUpCompanyEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
