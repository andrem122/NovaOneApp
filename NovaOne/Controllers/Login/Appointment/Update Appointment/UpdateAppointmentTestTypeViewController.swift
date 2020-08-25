//
//  UpdateAppointmentTestTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentTestTypeViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var testTypePicker: UIPickerView!
    let testTypes: [String] = Defaults.testTypes
    
    @IBOutlet weak var updateButton: NovaOneButton!
    lazy var selectedChoice: String = {
        guard
            let firstChoice = self.testTypes.first
        else { return "" }
        return firstChoice
    }()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        // Set up the picker view
        self.testTypePicker.delegate = self
        self.testTypePicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? AppointmentDetailViewController
        else { return }
        
        let updateClosure = {
            (appointment: Appointment) in
            appointment.testType = self.selectedChoice
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
            detailViewController.appointment = updatedAppointment
            detailViewController.coreDataObjectId = objectId
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.appointmentsMedical.rawValue, at: ["test_type": self.selectedChoice], endpoint: "/updateAppointmentMedicalAndRealEstate.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Appointment test type has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
    }
    
}

extension UpdateAppointmentTestTypeViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.testTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.testTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoice = self.testTypes[row]
    }
    
}

