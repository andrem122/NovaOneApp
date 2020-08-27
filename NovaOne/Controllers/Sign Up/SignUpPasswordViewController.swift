//
//  SignUpPasswordViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class SignUpPasswordViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var passwordTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpPassword.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpPassword.rawValue
        
        let userInfo = [AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpPassword.rawValue as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func setup() {
        
        self.passwordTextField.delegate = self
        
        // Get data from coredata if it is available and fill in password field if no state restoration text exists
        let filter = NSPredicate(format: "id == %@", "0")
        guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else {
            print("could not get coredata customer object - SignUpPasswordViewController")
            UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            return
        }
        
        guard let password = coreDataCustomerObject.password else {
            print("could not get core data customer password - SignUpPasswordViewController")
            return
        }
        
        self.passwordTextField.text = password
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        self.passwordTextField.becomeFirstResponder() // Make text field become first responder
    }
    
    // MARK: Actions
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.passwordTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let password = self.passwordTextField.text else { return }
        if password.count < 10 {
            let popUpOkViewController = self.alertService.popUpOk(title: "Password Length", body: "Password must be at least ten characters long.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let signUpNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpName.rawValue) as? SignUpNameViewController else { return }
            
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else { print("could not get coredata customer object - Sign Up Password View Controller"); return }
            coreDataCustomerObject.password = password
            
            PersistenceService.saveContext(context: nil)
            
            self.navigationController?.pushViewController(signUpNameViewController, animated: true)
        }
    }
    
}

extension SignUpPasswordViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
