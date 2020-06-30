//
//  UpdateAppointmentNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentNameViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var nameTextField: NovaOneTextField!
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.nameTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateValue = self.nameTextField.text != nil ? self.nameTextField.text!.trim() : ""
        if updateValue.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Enter Name", body: "Enter a name for the person with the appointment.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard
                let objectId = (self.updateObject as? Appointment)?.id,
                let detailViewController = self.previousViewController as? AppointmentDetailViewController
            else { return }
            
            let updateClosure = {
                (appointment: Appointment) in
                appointment.name = updateValue
            }
            
            let successDoneHandler = {
                [weak self] in
                
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
                
                detailViewController.appointment = updatedAppointment
                detailViewController.setupObjectDetailCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
                
                self?.removeSpinner()
                
            }
            
            self.updateObject(for: "appointments_appointment_base", at: ["name": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, successSubtitle: "Appointment name has been successfully updated.", successDoneHandler: successDoneHandler)
        }
    }
    
    
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.nameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
}

extension UpdateAppointmentNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
