//
//  AddLeadEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadEmailViewController: AddLeadBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        self.setupContinueButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailAddressTextField.becomeFirstResponder()
    }
    
    func setupTextField() {
        self.emailAddressTextField.delegate = self
    }
    
    func setupContinueButton() {
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    // MARK: Actions
    @IBAction func emailAddressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = emailAddressTextField.text else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: email) {
            guard let addLeadPhoneCheckViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadPhoneCheck.rawValue) as? AddLeadPhoneCheckViewController else { return }
            
            self.lead?.email = email
            addLeadPhoneCheckViewController.lead = self.lead
            addLeadPhoneCheckViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addLeadPhoneCheckViewController, animated: true)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension AddLeadEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
