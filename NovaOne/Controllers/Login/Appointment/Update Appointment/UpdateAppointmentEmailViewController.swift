//
//  UpdateAppointmentEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentEmailViewController: UpdateBaseViewController {

    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.emailAddressTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailAddressTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = emailAddressTextField.text?.trim() else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: updateValue) {
           guard
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? AppointmentDetailViewController
            else { return }
           
           let updateClosure = {
               (appointment: Appointment) in
               appointment.email = updateValue
           }
           
           let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
               detailViewController.appointment = updatedAppointment
               detailViewController.coreDataObjectId = objectId
               detailViewController.setupObjectDetailCellsAndTitle()
               detailViewController.objectDetailTableView.reloadData()
           }
           
            self.updateObject(for: Defaults.DataBaseTableNames.appointmentsMedical.rawValue, at: ["email": updateValue], endpoint: "/updateAppointmentMedicalAndRealEstate.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Appointment email has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func emailAddressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
}

extension UpdateAppointmentEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
