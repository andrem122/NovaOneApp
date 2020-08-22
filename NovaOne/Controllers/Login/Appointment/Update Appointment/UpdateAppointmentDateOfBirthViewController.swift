//
//  UpdateAppointmentDateOfBirthViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentDateOfBirthViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Get the selected date from the picker
        let updateValue = DateHelper.createString(from: self.dateOfBirthPicker.date, format: "yyyy-MM-dd")
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? AppointmentDetailViewController
        else { return }
        
        let updateClosure = {
            (appointment: Appointment) in
            appointment.dateOfBirth = self.dateOfBirthPicker.date
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
            
            detailViewController.coreDataObjectId = updatedAppointment.id
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.appointmentsMedical.rawValue, at: ["date_of_birth": updateValue], endpoint: "/updateAppointmentMedicalAndRealEstate.php", objectId: Int(objectId), objectType: Appointment.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Appointment date of birth has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
        
    }
    
}
