//
//  SignUpPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpPhoneViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var phoneTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpPhone.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpPhone.rawValue
        
        let textFieldText = self.phoneTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? false ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpPhone.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func continueFrom(activity: NSUserActivity) {
        // Restore the view controller to its previous state using the activity object plugged in from scene delegate method scene(_:willConnectTo:options:)
        let restoreText = activity.userInfo?[AppState.UserActivityKeys.signup.rawValue] as? String
        let continueButtonIsEnabled = activity.userInfo?[AppState.UserActivityKeys.signupButtonEnabled.rawValue] as? Bool
        self.restoreText = restoreText
        self.restoreContinueButtonState = continueButtonIsEnabled
    }
    
    func setup() {
        // Set delegates
        self.phoneTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
        
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            self.phoneTextField.text = self.restoreText
            
            // Restore button state
            guard let continueButtonState = self.restoreContinueButtonState else { return }
            if continueButtonState == true {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            } else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            }
        } else {
            // Get data from coredata if it is available and fill in the field if no state restoration text exists
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - SignUpPhoneViewController"); return }
            guard let phoneNumber = coreDataCustomerObject.phoneNumber else { print("could not get core data customer phone - SignUpPhoneViewController"); return }
            self.phoneTextField.text = phoneNumber
            
            // Enable the continue button
            UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.phoneTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Parameter values
        guard let phoneNumber = self.phoneTextField.text else { return }
        let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        if !unformattedPhoneNumber.isNumeric {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter only numbers.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            self.showSpinner(for: self.view, textForLabel: "Validating Phone Number")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": "%2B1" + unformattedPhoneNumber, "tableName": Defaults.DataBaseTableNames.customer.rawValue, "columnName": "phone_number"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(let success):
                    
                    print(success.successReason)
                    guard
                        let customerTypeViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue) as? SignUpCustomerTypeViewController
                    else { return }
                    
                    self?.customer?.phoneNumber = unformattedPhoneNumber
                    customerTypeViewController.customer = self?.customer
                    
                    // Get existing core data object and update it
                    let filter = NSPredicate(format: "id == %@", "0")
                    guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - Sign Up Phone View Controller"); return }
                    coreDataCustomerObject.phoneNumber = phoneNumber
                    PersistenceService.saveContext()
                    
                    self?.navigationController?.pushViewController(customerTypeViewController, animated: true)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let button = self?.continueButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner()
            }
        }
    }
    
}

extension SignUpPhoneViewController {
    
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
