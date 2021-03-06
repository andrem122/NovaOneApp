//
//  UpdateAppointmentPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import PhoneNumberKit

class UpdateAppointmentPhoneViewController: UpdateBaseViewController {

    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var phoneNumberTextField: NovaOneTextField!
    var phoneNumberKit: PhoneNumberKit?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.phoneNumberTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
        self.phoneNumberKit = PhoneNumberKit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.phoneNumberKit = nil
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Parameter values
        guard
            let phoneNumberText = self.phoneNumberTextField.text,
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
            print("Generic parser error - UpdateAppointmentPhoneViewController")
        }

        
        if phoneNumberIsValid == false {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter a valid phone number.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Disable button while doing HTTP request
            guard
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? AppointmentDetailViewController
                else { return }

            let updateClosure = {
                (appointment: Appointment) in
                appointment.phoneNumber = "+1" + unformattedPhoneNumber
            }

            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
                detailViewController.appointment = updatedAppointment
                detailViewController.coreDataObjectId = objectId
                detailViewController.setupObjectDetailCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }

            self.updateObject(for: Defaults.DataBaseTableNames.appointmentsBase.rawValue, at: ["phone_number": "+1" + unformattedPhoneNumber], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Appointment phone number has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
        }
    }
    
    @IBAction func phoneNumberTextChanged(_ sender: Any) {
    }
    
}

extension UpdateAppointmentPhoneViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var phoneNumber = textField.text else { return false }
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) {() -> Bool in
            
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
