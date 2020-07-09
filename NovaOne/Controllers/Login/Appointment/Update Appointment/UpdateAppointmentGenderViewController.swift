//
//  UpdateAppointmentGenderViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentGenderViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let genders = ["Male", "Female"]
    lazy var selectedChoice: String = {
        guard
            let firstGenderType = self.genders.first,
            let firstCharacter = firstGenderType.first
        else { return "" }
        return String(firstCharacter)
    }()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let objectId = (self.updateObject as? Appointment)?.id,
            let detailViewController = self.previousViewController as? AppointmentDetailViewController
        else { return }
        
        let updateClosure = {
            (appointment: Appointment) in
            appointment.gender = self.selectedChoice
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
        
        self.updateObject(for: Defaults.DataBaseTableNames.appointmentsMedical.rawValue, at: ["gender": self.selectedChoice], endpoint: "/updateAppointmentMedicalAndRealEstate.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, successSubtitle: "Appointment gender has been successfully updated.", successDoneHandler: successDoneHandler)
    }
    
}

extension UpdateAppointmentGenderViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoice = self.genders[row] == self.genders[0] ? "M" : "F"
    }
    
}
