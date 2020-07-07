//
//  UpdateAppointmentTimeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentTimeViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    var appointmentTimeIsAvailable: Bool = true
    var dispatchGroup = DispatchGroup()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTimePicker()
    }
    
    func setupTimePicker() {
        // Sets up the time picker
        self.timeDatePicker.minimumDate = Date() // Disable past dates and times for the picker
        self.timeDatePicker.minuteInterval = 30
    }
    
    func checkIfAppointmentTimeIsAvailable() {
        // Checks if appointment time selected is available
        print("Checking appointment availability")
        self.dispatchGroup.enter() // Indicate that the network request has begun
        self.appointmentTimeIsAvailable = true // Reset the value of self.appointmentTimeIsAvailable because it may have been set to false before
        self.showSpinner(for: self.view, textForLabel: "Updating Appointment")
        
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
                            let selectedDateTime = self?.timeDatePicker.date,
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
    
    func delete(appointment: Appointment) {
        // Deletes the old appointment from the database
        self.dispatchGroup.enter()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
            else { return }
        let customerUserId = customer.id

        let parameters: [String: Any] = ["customerUserId": String(customerUserId),
                                         "email": email,
                                         "password": password,
                                         "columnName": "id",
                                         "objectId": appointment.id,
                                         "tableName": "appointments_appointment_base"]
        
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/deleteAppointmentMedical.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
            switch result {
                case .success(_):
                    print("Appointment successfully deleted.")
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
            }
            self?.dispatchGroup.leave()
        }
    }
    
    func create(appointment: Appointment, for time: Date, detailViewController: AppointmentDetailViewController) {
        // Create a new appointment in the database based on customer type
        print("Creating appointment")
        guard let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first else { print("could not get customer object to create appointment"); return }
        print(appointment.name as Any)
        guard let name = appointment.name else { print("could not get appointment name"); return }
        guard let phoneNumber = appointment.phoneNumber else { print("could not get appointment phone number"); return }
        guard let time = appointment.time else { print("could not get appointment time"); return }
        let companyId = appointment.companyId
        let url = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
        var parameters: [String: Any] = ["name": name, "phone_number": phoneNumber, "time": time]
        
        // Add necessary parameters based on the customer
        if customer.customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            // Property managers
            guard let unitType = appointment.unitType else { print("could not create real estate appointment");return }
            parameters["unit_type"] = unitType
            
        } else {
            // Medical workers
            guard
                let testType = appointment.testType,
                let gender = appointment.gender,
                let dateOfBirth = appointment.dateOfBirth,
                let address = appointment.address,
                let email = appointment.email
                else { print("could not create medical appointment");return }
            
            parameters["test_type"] = testType
            parameters["gender"] = gender
            parameters["date_of_birth"] = dateOfBirth
            parameters["address"] = address
            parameters["email"] = email
        }
        
        // Make HTTP request to create an appointment
        let httpRequest = HTTPRequests()
        httpRequest.request(url: url, dataModel: SuccessResponse.self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(_):
                    // Redirect to success screen
                    
                    guard let successViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                    successViewController.subtitleText = "Appointment successfully updated."
                    successViewController.titleLabelText = "Appointment Updated!"
                    successViewController.doneHandler = {
                        [weak self] in
                        let predicate = NSPredicate(format: "id == %@", String(appointment.id))
                        guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
                        
                        detailViewController.appointment = updatedAppointment
                        detailViewController.setupObjectDetailCellsAndTitle()
                        detailViewController.objectDetailTableView.reloadData()
                        
                        self?.removeSpinner()
                    }
                    self?.present(successViewController, animated: true, completion: nil)
                case .failure(let error):
                    self?.removeSpinner()
                    guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOk, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check if appointment time is available before proceeding
        self.checkIfAppointmentTimeIsAvailable()
        
        self.dispatchGroup.notify(queue: .main) { // Only go forward after the network request has finished
            [weak self] in
            guard let appointmentTimeIsAvailable = self?.appointmentTimeIsAvailable else { print("appointment time unavailable"); return }
            if appointmentTimeIsAvailable {
                // Update the appointment time
                // Steps:
                // 1. Update the core data appointment object with the new time
                // 2. Delete the old appointment from the database
                // 3. Create a new appointment in the database with coredata information
                guard
                    let selectedDateTime = self?.timeDatePicker.date,
                    let appointment = self?.updateObject as? Appointment,
                    let detailViewController = self?.previousViewController as? AppointmentDetailViewController
                else { return }
                
                // Step 1 completed
                appointment.time = selectedDateTime
                PersistenceService.saveContext()
                
                // Step 2 completed
                self?.delete(appointment: appointment)
                
                self?.dispatchGroup.notify(queue: .main) {
                    // Step 3 completed
                    self?.create(appointment: appointment, for: selectedDateTime, detailViewController: detailViewController)
                }
            }
        }
        
    }
    
}
