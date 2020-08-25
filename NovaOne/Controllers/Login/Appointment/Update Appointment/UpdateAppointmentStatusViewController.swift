//
//  UpdateAppointmentStatusViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentStatusViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let statusChoices = ["Confirmed", "Not Confirmed"]
    var selectedChoice: String = "t" // postgres database takes values of "t" and "f" as boolean values
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? AppointmentDetailViewController
        else { return }
        
        let updateClosure = {
            (appointment: Appointment) in
            appointment.confirmed = self.selectedChoice == "t" ? true : false
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
            detailViewController.appointment = updatedAppointment
            detailViewController.coreDataObjectId = objectId
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.appointmentsBase.rawValue, at: ["confirmed": self.selectedChoice], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Appointment status has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
    }
    
}

extension UpdateAppointmentStatusViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.statusChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.statusChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoice = self.statusChoices[row] == self.statusChoices[0] ? "t" : "f"
    }
}
