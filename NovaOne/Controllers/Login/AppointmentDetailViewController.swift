//
//  NovaOneDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/6/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailCells: [[String : String]] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var topView: NovaOneView!
    let alertService: AlertService = AlertService()
    var appointment: AppointmentModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObjectDetailCellsAndTitle()
        self.setupTableView()
        self.setupTopView()
    }
    
    func setupTopView() {
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func setupTableView() {
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
    }
    
    func convert(appointment date: Date) -> String {
        // Convert date object to a string in a date format
        
        // Get dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let formattedDate: String = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Set cells up for the table view
        
        guard
            let appointment = self.appointment
        else { return }
        
        let appointmentTime: String = self.convert(appointment: appointment.timeDate)
        let appointmentCreated: String = self.convert(appointment: appointment.createdDate)
        let confirmedString = appointment.confirmed ? "Yes" : "No"
        let phoneNumber = appointment.phoneNumber
        
        // Create dictionaries for cells
        let phoneNumberCell = ["cellTitle": "Phone Number", "cellTitleValue": phoneNumber]
        let appointmentTimeCell = ["cellTitle": "Time", "cellTitleValue": appointmentTime]
        let appointmentCreatedCell = ["cellTitle": "Created", "cellTitleValue": appointmentCreated]
        let appointmentConfirmedCell = ["cellTitle": "Confirmed", "cellTitleValue": confirmedString]
        
        self.titleLabel.text = appointment.name
        self.objectDetailCells = [
            phoneNumberCell,
            appointmentTimeCell,
            appointmentCreatedCell,
            appointmentConfirmedCell]
        
        // Additional cells for different customer types
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let customerType = customer.customerType
        else { return }
        
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            guard let unitType = appointment.unitType else { return }
            let unitTypeCell = ["cellTitle": "Unit Type", "cellTitleValue": unitType]
            self.objectDetailCells.append(unitTypeCell)
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            guard
                let email = appointment.email,
                let dateOfBirth = appointment.dateOfBirth,
                let testType = appointment.testType,
                let gender = appointment.gender
            else { return }
            let address = appointment.shortenedAddress
            
            let emailCell = ["cellTitle": "Email", "cellTitleValue": email]
            let dateOfBirthCell = ["cellTitle": "Date Of Birth", "cellTitleValue": dateOfBirth]
            let testTypeCell = ["cellTitle": "Test Type", "cellTitleValue": testType]
            let genderCell = ["cellTitle": "Gender", "cellTitleValue": gender]
            let addressCell = ["cellTitle": "Address", "cellTitleValue": address]
            
            let cells = [emailCell, dateOfBirthCell, testTypeCell, genderCell, addressCell]
            self.objectDetailCells.append(contentsOf: cells)
            
        }
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete Appointment"
        let body = "Are you sure you want to delete the appointment?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle) {
            [weak self] in
            // Delete from CoreData
            
            // Delete from NovaOne database
            
            
            // Navigate to appointments container screen on tab bar controller and reload table to reflect changes
            if let homeTabBarController = self?.storyboard?.instantiateViewController(identifier: Defaults.TabBarControllerIdentifiers.home.rawValue) as? HomeTabBarController {
                
                homeTabBarController.modalPresentationStyle = .fullScreen
                homeTabBarController.selectedIndex = 1 // Select the appointments tab on the tab bar controller
                self?.present(homeTabBarController, animated: true, completion: nil)
                
            }
        }
        self.present(popUpViewController, animated: true, completion: nil)
    }
    
}

extension AppointmentDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailCell = self.objectDetailCells[indexPath.row]
        
        cell.setup(cellTitle: objectDetailCell["cellTitle"]!, cellTitleValue: objectDetailCell["cellTitleValue"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
