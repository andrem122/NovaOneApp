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
        let continueButtonState = textFieldText?.isEmpty ?? true ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func setupTextField() {
        self.propertyNameTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restore(textField: self.propertyNameTextField, continueButton: self.continueButton, coreDataEntity: Company.self) { (company) -> String in
            guard let company = company as? Company else { return "" }
            guard let companyName = company.name else { return "" }
            return companyName
        }
        self.setupTextField()
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
        
        // Create core data customer object or get it if it already exists for state restoration
        let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
        if count == 0 {
            let context = PersistenceService.privateChildManagedObjectContext()
            guard let coreDataCompanyObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.company.rawValue, into: context) as? Company else { return }
            
            coreDataCompanyObject.addCompany(address: "", created: Date(), daysOfTheWeekEnabled: "", email: "", hoursOfTheDayEnabled: "", id: 0, name: companyName, phoneNumber: "", shortenedAddress: "", city: "", customerUserId: 0, state: "", zip: "", autoRespondNumber: "", autoRespondText: "", customer: Customer(), allowSameDayAppointments: false)
            PersistenceService.saveContext(context: context)
        } else {
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - Sign Up Company Name View Controller"); return }
            coreDataCompanyObject.name = companyName
            
            // Save to CoreData for state restoration
            PersistenceService.saveContext(context: nil)
        }
        
        self.navigationController?.pushViewController(signUpCompanyAddressViewController, animated: true)
    }
    
}

extension SignUpCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
