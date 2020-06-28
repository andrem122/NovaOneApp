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
    var objectDetailItems: [ObjectDetailItem] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var topView: NovaOneView!
    let alertService: AlertService = AlertService()
    var appointment: Appointment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObjectDetailCellsAndTitle()
        self.setupTableView()
        self.setupTopView()
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        // Set up the navigation bar
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    func setupTopView() {
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func setupTableView() {
        // Set up the table view
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
        self.objectDetailTableView.rowHeight = 44;
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
            let appointment = self.appointment,
            let name = appointment.name,
            let time = appointment.time,
            let phoneNumber = appointment.phoneNumber
        else { return }
        
        let appointmentTime: String = self.convert(appointment: time)
        let confirmedString = appointment.confirmed ? "Yes" : "No"
        
        // Create items for cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let appointmentTimeItem = ObjectDetailItem(titleValue: appointmentTime, titleItem: .appointmentTime)
        let appointmentConfirmedItem = ObjectDetailItem(titleValue: confirmedString, titleItem: .confirmed)
        
        self.titleLabel.text = appointment.name
        self.objectDetailItems = [
            nameItem,
            phoneNumberItem,
            appointmentTimeItem,
            appointmentConfirmedItem]
        
        // Additional cells for different customer types
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let customerType = customer.customerType
        else { return }
        
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            guard let unitType = appointment.unitType else { return }
            let unitTypeItem = ObjectDetailItem(titleValue: unitType, titleItem: .unitType)
            self.objectDetailItems.append(unitTypeItem)
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            guard
                let email = appointment.email,
                let dateOfBirthDate = appointment.dateOfBirth,
                let testType = appointment.testType,
                let gender = appointment.gender,
                let address = appointment.address
            else { return }
            let dateOfBirth = DateHelper.createString(from: dateOfBirthDate, format: "MM/DD/yyyy")
            
            let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
            let dateOfBirthItem = ObjectDetailItem(titleValue: dateOfBirth, titleItem: .dateOfBirth)
            let testTypeItem = ObjectDetailItem(titleValue: testType, titleItem: .testType)
            let genderItem = ObjectDetailItem(titleValue: gender, titleItem: .gender)
            let addressItem = ObjectDetailItem(titleValue: address, titleItem: .address)
            
            let items = [emailItem, dateOfBirthItem, testTypeItem, genderItem, addressItem]
            self.objectDetailItems.append(contentsOf: items)
            
        }
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete Appointment"
        let body = "Are you sure you want to delete the appointment?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
            [weak self] in
            // Delete from CoreData
            
            // Delete from NovaOne database
            
            
            // Navigate to appointments container screen on tab bar controller and reload table to reflect changes
            if let homeTabBarController = self?.storyboard?.instantiateViewController(identifier: Defaults.TabBarControllerIdentifiers.home.rawValue) as? HomeTabBarController {
                
                homeTabBarController.modalPresentationStyle = .fullScreen
                homeTabBarController.selectedIndex = 1 // Select the appointments tab on the tab bar controller
                self?.present(homeTabBarController, animated: true, completion: nil)
                
            }
        }, cancelHandler: {
            print("Action canceled")
        })
        
        self.present(popUpViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AppointmentDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailItem = self.objectDetailItems[indexPath.row]
        cell.objectDetailItem = objectDetailItem
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
            
            // Get company title based on which row the user taps on
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        
            // Get update view controller based on which cell the user clicked on
            switch titleItem {
                case .name:
                    if let updateAppointmentNameViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentName.rawValue) as? UpdateAppointmentNameViewController {
                        
                        updateAppointmentNameViewController.updateObject = self.appointment
                        updateAppointmentNameViewController.previousViewController = self
                        
                        self.navigationController?.pushViewController(updateAppointmentNameViewController, animated: true)
                        
                    }
                case .email:
                        if let updateAppointmentEmailViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentEmail.rawValue) as? UpdateAppointmentEmailViewController {
                            
                            updateAppointmentEmailViewController.updateObject = self.appointment
                            updateAppointmentEmailViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentEmailViewController, animated: true)
                            
                        }
                    
                case .phoneNumber:
                        if let updateAppointmentPhoneViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentPhone.rawValue) as? UpdateAppointmentPhoneViewController {
                            
                            updateAppointmentPhoneViewController.updateObject = self.appointment
                            updateAppointmentPhoneViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentPhoneViewController, animated: true)
                            
                        }
                    
                case .appointmentTime:
                        if let updateAppointmentTimeViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentTime.rawValue) as? UpdateAppointmentTimeViewController {
                            
                            updateAppointmentTimeViewController.updateObject = self.appointment
                            updateAppointmentTimeViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentTimeViewController, animated: true)
                            
                        }
                    
                case .confirmed:
                        if let updateAppointmentStatusViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentStatus.rawValue) as? UpdateAppointmentStatusViewController {
                            
                            updateAppointmentStatusViewController.updateObject = self.appointment
                            updateAppointmentStatusViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentStatusViewController, animated: true)
                            
                        }
                    
                case .dateOfBirth:
                        if let updateAppointmentDateOfBirthViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentDateOfBirth.rawValue) as? UpdateAppointmentDateOfBirthViewController {
                            
                            updateAppointmentDateOfBirthViewController.updateObject = self.appointment
                            updateAppointmentDateOfBirthViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentDateOfBirthViewController, animated: true)
                            
                        }
                    
                case .unitType:
                        if let updateAppointmentUnitTypeViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentUnitType.rawValue) as? UpdateAppointmentUnitTypeViewController {
                            
                            updateAppointmentUnitTypeViewController.updateObject = self.appointment
                            updateAppointmentUnitTypeViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentUnitTypeViewController, animated: true)
                            
                        }
                    
                case .testType:
                        if let updateAppointmentTestTypeViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentTestType.rawValue) as? UpdateAppointmentTestTypeViewController {
                            
                            updateAppointmentTestTypeViewController.updateObject = self.appointment
                            updateAppointmentTestTypeViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentTestTypeViewController, animated: true)
                            
                        }
                    
                case .gender:
                        if let updateAppointmentGenderViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentGender.rawValue) as? UpdateAppointmentGenderViewController {
                            
                            updateAppointmentGenderViewController.updateObject = self.appointment
                            updateAppointmentGenderViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentGenderViewController, animated: true)
                            
                        }
                    
                case .address:
                        if let updateAppointmentAddressViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentAddress.rawValue) as? UpdateAppointmentAddressViewController {
                            
                            updateAppointmentAddressViewController.updateObject = self.appointment
                            updateAppointmentAddressViewController.previousViewController = self
                            
                            self.navigationController?.pushViewController(updateAppointmentAddressViewController, animated: true)
                            
                        }
                    
                    default:
                        print("No cases matched")
            }

    }
    
}
