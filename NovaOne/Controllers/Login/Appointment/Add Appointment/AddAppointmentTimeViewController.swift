//
//  AddAppointmentTimeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentTimeViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Show the next view controller based on the customer type
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let customerType = customer.customerType
        else { return }
        let appointmentTime = DateHelper.createString(from: self.appointmentTimePicker.date, format: "yyyy-MM-dd HH:mm:ss zzz")
        self.appointment?.time = appointmentTime
        
        // For property managers
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            // Navigate to add appointment unit type view controller
            guard let addAppointmentUnitTypeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue) as? AddAppointmentUnitTypeViewController else { return }
            addAppointmentUnitTypeViewController.appointment = self.appointment
            self.navigationController?.pushViewController(addAppointmentUnitTypeViewController, animated: true)
            
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            // Navigate to add appointment email view controller
            guard let addAppointmentEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue) as? AddAppointmentEmailViewController else { return }
            addAppointmentEmailViewController.appointment = self.appointment
            self.navigationController?.pushViewController(addAppointmentEmailViewController, animated: true)
            
        }
        
    }

}
