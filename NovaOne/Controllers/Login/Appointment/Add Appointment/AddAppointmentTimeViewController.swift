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
    var hoursEnabled: [Int]?
    var daysEnabled: [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTimePicker()
    }
    
    func setupTimePicker() {
        // Sets up the time picker
        self.appointmentTimePicker.minimumDate = Date() // Disable past dates and times for the picker
        self.appointmentTimePicker.minuteInterval = 30
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {

        // Get customer object to get customer type
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerType = customer.customerType
        else { return }
        
        // Get appointment time from date picker
        let appointmentTime = DateHelper.createString(from: self.appointmentTimePicker.date, format: "MM/dd/yyyy hh:mm a")
        self.appointment?.time = appointmentTime
        
        // Show the next view controller based on the customer type
        // For property managers
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            // Navigate to add appointment unit type view controller
            guard let addAppointmentUnitTypeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue) as? AddAppointmentUnitTypeViewController else { return }
            
            addAppointmentUnitTypeViewController.appointment = self.appointment
            addAppointmentUnitTypeViewController.appointmentsTableViewController = self.appointmentsTableViewController
            
            self.navigationController?.pushViewController(addAppointmentUnitTypeViewController, animated: true)
            
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            // Navigate to add appointment email view controller
            guard let addAppointmentEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue) as? AddAppointmentEmailViewController else { return }
            
            addAppointmentEmailViewController.appointment = self.appointment
            
            self.navigationController?.pushViewController(addAppointmentEmailViewController, animated: true)
            
        }
        
    }

}
