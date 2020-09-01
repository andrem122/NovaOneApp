//
//  AddAppointmentPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import PhoneNumberKit

class AddAppointmentPhoneViewController: AddAppointmentBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var appointmentPhoneTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    var phoneNumberKit: PhoneNumberKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContinueButton()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appointmentPhoneTextField.becomeFirstResponder()
        self.phoneNumberKit = PhoneNumberKit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.phoneNumberKit = nil
    }
    
    func setupTextField() {
        // Set up the text field
        self.appointmentPhoneTextField.delegate = self
    }
    
    func setupContinueButton() {
        // Setup the continue button
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }

    // MARK: Actions
    @IBAction func appointmentPhoneTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.appointmentPhoneTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard
            let phoneNumberText = self.appointmentPhoneTextField.text,
        let phoneNumberKit = self.phoneNumberKit
        else { return }
        let unformattedPhoneNumber = phoneNumberText.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        var phoneNumberIsValid = false
        do {
            let _ = try phoneNumberKit.parse(phoneNumberText, withRegion: "US")
            phoneNumberIsValid = true
        }
        catch {
            phoneNumberIsValid = false
            print("Generic parser error - AddAppointmentPhoneViewController")
        }
        
        // Check of phone number is valid before proceeding
        if phoneNumberIsValid == false {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter a valid phone number.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let addAppointmentTimeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentTime.rawValue) as? AddAppointmentTimeViewController else { return }
            
            self.appointment?.phoneNumber = "+1" + unformattedPhoneNumber
            addAppointmentTimeViewController.appointment = self.appointment
            addAppointmentTimeViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addAppointmentTimeViewController, animated: true)
        }
    }
}

extension AddAppointmentPhoneViewController {
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
