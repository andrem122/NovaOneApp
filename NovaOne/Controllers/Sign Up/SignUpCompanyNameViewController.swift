//
//  SignUpPropertyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCompanyNameViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var propertyNameTextField: NovaOneTextField!
    
    // MARK: Methods
    func setup() {
        self.propertyNameTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
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
        
        self.company = CompanyModel(id: 0, name: companyName, address: "", phoneNumber: "", autoRespondNumber: nil, autoRespondText: nil, email: "", created: "", daysOfTheWeekEnabled: "", hoursOfTheDayEnabled: "", city: "", customerUserId: 0, state: "", zip: "")
        signUpCompanyAddressViewController.company = self.company
        signUpCompanyAddressViewController.customer = self.customer
        
        self.navigationController?.pushViewController(signUpCompanyAddressViewController, animated: true)
    }
    
}

extension SignUpCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
