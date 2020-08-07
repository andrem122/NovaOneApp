//
//  SignUpEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class SignUpEmailViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpEmail.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpEmail.rawValue
        
        let textFieldText = self.emailAddressTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? false ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: self.emailAddressTextField.text as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpEmail.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    func continueFrom(activity: NSUserActivity) {
        // Restore the view controller to its previous state using the activity object plugged in from scene delegate method scene(_:willConnectTo:options:)
        let restoreText = activity.userInfo?[AppState.UserActivityKeys.signup.rawValue] as? String
        let continueButtonIsEnabled = activity.userInfo?[AppState.UserActivityKeys.signupButtonEnabled.rawValue] as? Bool
        self.restoreText = restoreText
        self.restoreContinueButtonState = continueButtonIsEnabled
    }
    
    // MARK: Methods
    func setup() {
        
        // Set delegates
        self.emailAddressTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
        
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            self.emailAddressTextField.text = self.restoreText
            
            // Restore button state
            guard let continueButtonState = self.restoreContinueButtonState else { return }
            if continueButtonState == true {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            } else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            }
        } else {
            // Get data from coredata if it is available and fill in email field if no state restoration text exists
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - Sign Up Email View Controller"); return }
            guard let email = coreDataCustomerObject.email else { print("could not get core data customer email - - Sign Up Email View Controller"); return }
            self.emailAddressTextField.text = email
            
            // Enable the continue button
            UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        self.emailAddressTextField.becomeFirstResponder() // Make text field become first responder
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Dismiss this view controller on tap of the cancel button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        // Delete all customer data from coredata
        PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.customer.rawValue)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = emailAddressTextField.text else { return }
        
        // If email is valid, check for it in the database before continuing
        if InputValidators.isValidEmail(email: email) {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            self.showSpinner(for: self.view, textForLabel: "Validating Email")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": email, "tableName": Defaults.DataBaseTableNames.authUser.rawValue, "columnName": "email"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(let success):
                    
                    print(success.successReason)
                    self?.customer = CustomerModel(id: 0, userId: 0, password: "", lastLogin: "", username: email, firstName: "", lastName: "", email: email, dateJoined: "", isPaying: false, wantsSms: false, wantsEmailNotifications: true, phoneNumber: "", customerType: "")
                    
                    // Create core data customer object or get it if it already exists for state restoration
                    let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.customer.rawValue)
                    if count == 0 {
                        guard let coreDataCustomerObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.customer.rawValue, into: PersistenceService.context) as? Customer else { return }
                        
                        coreDataCustomerObject.addCustomer(customerType: "", dateJoined: Date(), email: email, firstName: "", id: 0, userId: 0, isPaying: false, lastName: "", phoneNumber: "", wantsSms: false, wantsEmailNotifications: false, password: "", username: email, lastLogin: Date(), companies: nil)
                    } else {
                        // Get existing core data object and update it
                        let filter = NSPredicate(format: "id == %@", "0")
                        guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - Sign Up Email View Controller"); return }
                        coreDataCustomerObject.email = email
                    }
                    
                    // Save to CoreData for state restoration
                    PersistenceService.saveContext()
                    
                    guard let signUpPasswordViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpPassword.rawValue) as? SignUpPasswordViewController else { return }
                    signUpPasswordViewController.customer = self?.customer
                    self?.navigationController?.pushViewController(signUpPasswordViewController, animated: true)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let button = self?.continueButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner()
            }
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func emailFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
    }
    
}

extension SignUpEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
