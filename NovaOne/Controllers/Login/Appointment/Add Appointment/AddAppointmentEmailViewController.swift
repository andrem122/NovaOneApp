//
//  AddAppointmentEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentEmailViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailAddressTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func emailAddressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = emailAddressTextField.text else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: email) {
            guard let addAppointmentAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentAddress.rawValue) as? AddAppointmentAddressViewController else { return }
            
            self.appointment?.email = email
            addAppointmentAddressViewController.appointment = self.appointment
            
            self.navigationController?.pushViewController(addAppointmentAddressViewController, animated: true)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
}
