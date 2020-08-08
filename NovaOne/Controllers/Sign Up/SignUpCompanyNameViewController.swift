//
//  SignUpPropertyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class SignUpCompanyNameViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var propertyNameTextField: NovaOneTextField!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue
        
        let textFieldText = self.propertyNameTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? false ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
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
        self.propertyNameTextField.delegate = self
        
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            self.propertyNameTextField.text = self.restoreText
            
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
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
                print("could not get coredata company object - SignUpCompanyViewController")
                return
            }
            guard let companyName = coreDataCustomerObject.phoneNumber else { print("could not get core data company name - SignUpCompanyViewController"); return }
            self.propertyNameTextField.text = companyName
            
            // Enable the continue button
            if companyName.isEmpty {
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
        
        // Make text field become first responder
        self.propertyNameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func propertyNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.propertyNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard
            let signUpCompanyAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue) as? SignUpCompanyAddressViewController,
            let companyName = self.propertyNameTextField.text
        else { return }
        
        self.company = CompanyModel(id: 0, name: companyName, address: "", phoneNumber: "", autoRespondNumber: nil, autoRespondText: nil, email: "", created: "", allowSameDayAppointments: false, daysOfTheWeekEnabled: "", hoursOfTheDayEnabled: "", city: "", customerUserId: 0, state: "", zip: "")
        signUpCompanyAddressViewController.company = self.company
        signUpCompanyAddressViewController.customer = self.customer
        
        // Create core data customer object or get it if it already exists for state restoration
        let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
        if count == 0 {
            guard let coreDataCompanyObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.company.rawValue, into: PersistenceService.context) as? Company else { return }
            
            coreDataCompanyObject.addCompany(address: "", created: Date(), daysOfTheWeekEnabled: "", email: "", hoursOfTheDayEnabled: "", id: 0, name: companyName, phoneNumber: "", shortenedAddress: "", city: "", customerUserId: 0, state: "", zip: "", autoRespondNumber: "", autoRespondText: "", customer: Customer(), allowSameDayAppointments: false)
        } else {
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - Sign Up Company Name View Controller"); return }
            coreDataCompanyObject.name = companyName
        }
        
        // Save to CoreData for state restoration
        PersistenceService.saveContext()
        
        self.navigationController?.pushViewController(signUpCompanyAddressViewController, animated: true)
    }
    
}

extension SignUpCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
