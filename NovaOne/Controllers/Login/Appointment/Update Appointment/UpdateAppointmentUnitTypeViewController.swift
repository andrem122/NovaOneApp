//
//  UpdateAppointmentUnitTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentUnitTypeViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var unitTypePicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let unitTypes = ["1 Bedroom", "2 Bedrooms", "3 Bedrooms"]
    lazy var selectedChoice: String = {
        guard
            let firstChoice = self.unitTypes.first
        else { return "" }
        return firstChoice
    }()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.unitTypePicker.delegate = self
        self.unitTypePicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let objectId = (self.updateObject as? Appointment)?.id,
            let detailViewController = self.previousViewController as? AppointmentDetailViewController
        else { return }
        
        let updateClosure = {
            (appointment: Appointment) in
            appointment.unitType = self.selectedChoice
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
        
        self.updateObject(for: Defaults.DataBaseTableNames.appointmentsRealEstate.rawValue, at: ["unit_type": self.selectedChoice], endpoint: "/updateAppointmentMedicalAndRealEstate.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, successSubtitle: "Appointment unit type has been successfully updated.", successDoneHandler: successDoneHandler)
    }
}

extension UpdateAppointmentUnitTypeViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.unitTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.unitTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoice = self.unitTypes[row]
    }
    
}
