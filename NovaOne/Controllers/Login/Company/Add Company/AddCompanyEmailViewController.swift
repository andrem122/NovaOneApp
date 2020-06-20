//
//  AddCompanyEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyEmailViewController: AddCompanyBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var companyEmailTextField: NovaOneTextField!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContinueButton()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.companyEmailTextField.becomeFirstResponder()
    }
    
    func setupContinueButton() {
        // Setup the continue button
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    func setupTextField() {
        // Setup the text field
        self.companyEmailTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = companyEmailTextField.text else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: email) {
            guard let addCompanyPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyPhone.rawValue) as? AddCompanyPhoneViewController else { return }
            
            self.company?.email = email
            addCompanyPhoneViewController.company = self.company
            addCompanyPhoneViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addCompanyPhoneViewController, animated: true)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func companyEmailFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.companyEmailTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
}

extension AddCompanyEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
