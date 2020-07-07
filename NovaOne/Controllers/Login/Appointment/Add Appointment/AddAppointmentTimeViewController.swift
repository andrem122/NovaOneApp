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
    var appointmentTimeIsAvailable: Bool = true
    var dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTimePicker()
    }
    
    func setupTimePicker() {
        // Sets up the time picker
        self.appointmentTimePicker.minimumDate = Date() // Disable past dates and times for the picker
        self.appointmentTimePicker.minuteInterval = 30
    }
    
    func checkIfAppointmentTimeIsAvailable() {
        // Checks if appointment time selected is available
        
        self.dispatchGroup.enter() // Indicate that the network request has begun
        self.appointmentTimeIsAvailable = true // Reset the value of self.appointmentTimeIsAvailable because it may have been set to false before
        self.showSpinner(for: self.view, textForLabel: "Checking Availability...")
        
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id

        let parameters: [String: String] = ["customerUserId": String(customerUserId),
                                         "email": email,
                                         "password": password]
        
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/appointments.php", dataModel: [AppointmentModel].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let appointments):
                    // Loop through appointments and see if any conflict with the time selected by the user
                    for appointment in appointments {
                        // If the appointment time selected is at the same time as another appointment OR
                        // the appointment falls within the 30 minute appointment time slot
                        // present an error with a popup OK view controller
                        
                        // Check if selected time falls in the alotted time for each appointment
                        let appointmentDateTime = appointment.timeDate
                        guard
                            let selectedDateTime = self?.appointmentTimePicker.date,
                            let thirtyMinutesAfterApppointmentTime = Calendar.current.date(byAdding: .minute, value: 30, to: appointmentDateTime)
                        else {
                            self?.appointmentTimeIsAvailable = false
                            return
                        }
                        
                        let fallsBetween = (appointmentDateTime..<thirtyMinutesAfterApppointmentTime).contains(selectedDateTime) // Include the start (lower bounds of the range) date and time but NOT the end (upper bound of the range) date and time in the range
                        if fallsBetween {
                            guard let popUpOkViewController = self?.alertService.popUpOk(title: "Time Unavailable", body: "An appointment has already been made for this time. Please select a different time.") else { return }
                            self?.present(popUpOkViewController, animated: true, completion: nil)
                            
                            self?.appointmentTimeIsAvailable = false
                            self?.removeSpinner()
                            break // Break out of the loop and continue with the code below
                        }
                    }
                case .failure(let error):
                    
                    // If there are no appointments, make appointmentTimeIsAvailable equal to true and do NOT show a pop up
                    if error.localizedDescription == Defaults.ErrorResponseReasons.noData.rawValue {
                        self?.appointmentTimeIsAvailable = true
                    } else {
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                       self?.appointmentTimeIsAvailable = false
                    }
                    
            }
            
            self?.removeSpinner()
            self?.dispatchGroup.leave() // Indicate that the network request has ended
        }
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Check if appointment time is available before proceeding
        self.checkIfAppointmentTimeIsAvailable()
        
        self.dispatchGroup.notify(queue: .main) { // Only go forward after the network request has finished
            [weak self] in
            guard let appointmentTimeIsAvailable = self?.appointmentTimeIsAvailable else { return }
            if appointmentTimeIsAvailable {
                
                // Get customer object to get customer type
                guard
                    let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                    let customerType = customer.customerType
                else { return }
                
                // Get appointment time from date picker
                guard let selectedDateTime = self?.appointmentTimePicker.date else { return }
                let appointmentTime = DateHelper.createString(from: selectedDateTime, format: "MM/dd/yyyy hh:mm a")
                self?.appointment?.time = appointmentTime
                
                // Show the next view controller based on the customer type
                // For property managers
                if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
                    
                    // Navigate to add appointment unit type view controller
                    guard let addAppointmentUnitTypeViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue) as? AddAppointmentUnitTypeViewController else { return }
                    
                    addAppointmentUnitTypeViewController.appointment = self?.appointment
                    addAppointmentUnitTypeViewController.appointmentsTableViewController = self?.appointmentsTableViewController
                    
                    self?.navigationController?.pushViewController(addAppointmentUnitTypeViewController, animated: true)
                    
                    
                } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
                    
                    // Navigate to add appointment email view controller
                    guard let addAppointmentEmailViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue) as? AddAppointmentEmailViewController else { return }
                    
                    addAppointmentEmailViewController.appointment = self?.appointment
                    
                    self?.navigationController?.pushViewController(addAppointmentEmailViewController, animated: true)
                    
                }
            }
        }
        
    }

}
