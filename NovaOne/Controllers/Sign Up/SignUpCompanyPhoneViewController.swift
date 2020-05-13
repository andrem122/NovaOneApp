//
//  SignUpPropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCompanyPhoneViewController: BaseSignUpViewController {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var propertyPhoneTextField: NovaOneTextField!
    
    // MARK: Methods
    func setup() {
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
        // Navigate to the add company hours enabled view controller
        if let addCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue) as? AddCompanyDaysEnabledViewController {
            
            addCompanyDaysEnabledViewController.userIsSigningUp = true // Indicates that the user is new and signing up and not an existing user adding a company
            self.navigationController?.pushViewController(addCompanyDaysEnabledViewController, animated: true)
            
        }
    }
    
}
