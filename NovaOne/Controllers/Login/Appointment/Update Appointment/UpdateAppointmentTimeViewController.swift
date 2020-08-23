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
    
    func checkIfAppointmentTimeIsAvailable() -> UIView {
        // Checks if appointment time selected is available
        print("Checking appointment availability")
        self.dispatchGroup.enter() // Indicate that the network request has begun
        self.appointmentTimeIsAvailable = true // Reset the value of self.appointmentTimeIsAvailable because it may have been set to false before
        let spinnerView = self.showSpinner(for: self.view, textForLabel: "Updating")
        
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return spinnerView }
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
                            self?.removeSpinner(spinnerView: spinnerView)
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
            
            self?.dispatchGroup.leave() // Indicate that the network request has ended
        }
        
        return spinnerView
    }
    
    func delete(appointment: Appointment) {
        // Deletes the old appointment from the database
        self.dispatchGroup.enter()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerType = customer.customerType,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
            else { return }
        let customerUserId = customer.id

        let parameters: [String: Any] = ["customerUserId": String(customerUserId),
                                         "email": email,
                                         "password": password,
                                         "columnName": "id",
                                         "objectId": appointment.id,
                                         "tableName": Defaults.DataBaseTableNames.appointmentsBase.rawValue]
        
        let endpoint = customerType == Defaults.CustomerTypes.medicalWorker.rawValue ? "/deleteAppointmentMedical.php" : "/deleteAppointmentRealEstate.php"
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint, dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
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
    
    func create(appointment: Appointment, for time: Date, detailViewController: AppointmentDetailViewController, spinnerView: UIView) {
        // Create a new appointment in the database based on customer type
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let name = appointment.name,
            let phoneNumber = appointment.phoneNumber
        else { return }
        let updatedAppointmentTime = DateHelper.createString(from: time, format: "MM/dd/yyyy h:mm a")
        let companyId = appointment.companyId
        let url = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
        var parameters: [String: Any] = ["name": name, "phone_number": phoneNumber, "time": updatedAppointmentTime]
        
        // Add necessary parameters based on the customer
        if customer.customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            // Property managers
            guard let unitType = appointment.unitType else { return }
            parameters["unit_type"] = unitType
            
        } else {
            // Medical workers
            guard
                let testType = appointment.testType,
                let gender = appointment.gender,
                let dateOfBirth = appointment.dateOfBirth,
                let address = appointment.address,
                let email = appointment.email
            else { return }
            let dateOfBirthString = DateHelper.createString(from: dateOfBirth, format: "MM/dd/yyyy")
            
            parameters["test_type"] = testType
            parameters["gender"] = gender
            parameters["date_of_birth"] = dateOfBirthString
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
                    // Update appointment object
                    let newAppointmentId = appointment.id + 1
                    appointment.time = time
                    appointment.id = newAppointmentId
                    PersistenceService.saveContext()
                    
                    let popupStoryboard = UIStoryboard(name: Defaults.StoryBoards.popups.rawValue, bundle: .main)
                    guard let successViewController = popupStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                    successViewController.subtitleText = "Appointment time has been successfully updated."
                    successViewController.titleLabelText = "Update Complete!"
                    successViewController.doneHandler = {
                        let predicate = NSPredicate(format: "id == %@", String(newAppointmentId))
                        guard let updatedAppointment = PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil).first else { return }
                        
                        detailViewController.coreDataObjectId = updatedAppointment.id
                        detailViewController.setupObjectDetailCellsAndTitle()
                        detailViewController.objectDetailTableView.reloadData()
                        
                        self?.removeSpinner(spinnerView: spinnerView)
                    }
                    
                    // Get detail view controller instance
                    guard let objectDetailViewController = self?.previousViewController as? NovaOneObjectDetail else { print("could not get objectDetailViewController - UpdateAppointmentTimeViewController"); return }
                    
                    // Get table view controller
                    guard let tableViewController = objectDetailViewController.previousViewController as? AppointmentsTableViewController else { print("could not get AppointmentsTableViewController - UpdateAppointmentTimeViewController"); return }
                    
                    // Remove update view controller and present success view controller
                    (objectDetailViewController as? UIViewController)?.dismiss(animated: false, completion: {
                        // Do not have to remove spinner view after dismissing update view because when the update
                        // view is dismissed it removes the spinner view
                        (objectDetailViewController as? UIViewController)?.present(successViewController, animated: true, completion: {
                            guard let sizeClass = self?.getSizeClass() else { return }
                            if sizeClass == (.regular, .compact) || sizeClass == (.regular, .regular) || sizeClass == (.regular, .unspecified) {
                                tableViewController.didSetFirstItem = false // Set equal to false so the table view controller will set the first item in the detail view again with fresh properties, so we don't get update errors
                                tableViewController.setFirstItemForDetailView()
                            }
                        })
                        
                    })
                case .failure(let error):
                    guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOk, animated: true, completion: nil)
            }
            
            self?.removeSpinner(spinnerView: spinnerView)
        }
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check if appointment time is available before proceeding
        let spinnerView = self.checkIfAppointmentTimeIsAvailable()
        
        self.dispatchGroup.notify(queue: .main) { // Only go forward after the network request has finished
            [weak self] in
            guard let appointmentTimeIsAvailable = self?.appointmentTimeIsAvailable else { return }
            if appointmentTimeIsAvailable {
                guard
                    let selectedDateTime = self?.timeDatePicker.date,
                    let appointmentId = self?.updateCoreDataObjectId,
                    let detailViewController = self?.previousViewController as? AppointmentDetailViewController
                else { return }
                
                let filter = NSPredicate(format: "id == %@", String(appointmentId))
                guard let appointment = PersistenceService.fetchEntity(Appointment.self, filter: filter, sort: nil).first else { print("could not get appointment object - UpdateAppointmentTimeViewController"); return }
                
                self?.delete(appointment: appointment)
                
                self?.dispatchGroup.notify(queue: .main) {
                    // Step 3 completed
                    self?.create(appointment: appointment, for: selectedDateTime, detailViewController: detailViewController, spinnerView: spinnerView)
                }
            }
        }
        
    }
    
}
