//
//  AddCompanyHoursEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class AddCompanyHoursEnabledViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addCompanyEnabledHoursTableView: UITableView!
    @IBOutlet weak var appointmentHoursButton: NovaOneButton!
    let alertService = AlertService()
    let coreDataCustomerEmail: String? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first?.email
    var userIsSigningUp: Bool = false // A Boolean that indicates whether or not the current user is new and signing up
    
    var hoursOfTheDayAM: [EnableOption] = [
        EnableOption(option: "12:00", selected: false, id: 0),
        EnableOption(option: "1:00", selected: false, id: 1),
        EnableOption(option: "2:00", selected: false, id: 2),
        EnableOption(option: "3:00", selected: false, id: 3),
        EnableOption(option: "4:00", selected: false, id: 4),
        EnableOption(option: "5:00", selected: false, id: 5),
        EnableOption(option: "6:00", selected: false, id: 6),
        EnableOption(option: "7:00", selected: false, id: 7),
        EnableOption(option: "8:00", selected: false, id: 8),
        EnableOption(option: "9:00", selected: false, id: 9),
        EnableOption(option: "10:00", selected: false, id: 10),
        EnableOption(option: "11:00", selected: false, id: 11),
    ]
    
    var hoursOfTheDayPM: [EnableOption] = [
        EnableOption(option: "12:00", selected: false, id: 12),
        EnableOption(option: "1:00", selected: false, id: 13),
        EnableOption(option: "2:00", selected: false, id: 14),
        EnableOption(option: "3:00", selected: false, id: 15),
        EnableOption(option: "4:00", selected: false, id: 16),
        EnableOption(option: "5:00", selected: false, id: 17),
        EnableOption(option: "6:00", selected: false, id: 18),
        EnableOption(option: "7:00", selected: false, id: 19),
        EnableOption(option: "8:00", selected: false, id: 20),
        EnableOption(option: "9:00", selected: false, id: 21),
        EnableOption(option: "10:00", selected: false, id: 22),
        EnableOption(option: "11:00", selected: false, id: 23),
    ]
    
    // For sign up process
    var company: CompanySignUpModel?
    var customer: CustomerSignUpModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setButtonTitle()
    }
    
    func setupTableView() {
        // Set delegate and datasource for table view
        self.addCompanyEnabledHoursTableView.delegate = self
        self.addCompanyEnabledHoursTableView.dataSource = self
    }
    
    func setButtonTitle() {
        // Set the title for the appointment hours button
        if self.userIsSigningUp {
            self.appointmentHoursButton.setTitle("Finish Sign Up", for: .normal)
        }
    }
    
    func signupUser(success: @escaping (String, String) -> Void) {
        // Send a POST request to signup api
        
        // Unwrap needed POST data from objects
        guard
            let email = self.customer?.email,
            let password = self.customer?.password,
            let firstName = self.customer?.firstName,
            let lastName = self.customer?.lastName,
            let phoneNumber = self.customer?.phoneNumber,
            let customerType = self.customer?.customerType,
            let companyName = self.company?.name,
            let companyAddress = self.company?.address,
            let companyPhoneNumber = self.company?.phoneNumber,
            let companyEmail = self.company?.email,
            let companyDaysEnabled = self.company?.daysOfTheWeekEnabled,
            let companyHoursEnabled = self.company?.hoursOfTheDayEnabled,
            let companyCity = self.company?.city,
            let companyState = self.company?.state,
            let companyZip = self.company?.zip
        else { return }
        
        let parameters: [String: String] = ["email": email,
                                            "password": password,
                                            "firstName": firstName,
                                            "lastName": lastName,
                                            "phoneNumber": phoneNumber,
                                            "customerType": customerType,
                                            "companyName": companyName,
                                            "companyAddress": companyAddress,
                                            "companyPhoneNumber": companyPhoneNumber,
                                            "companyEmail": companyEmail,
                                            "companyDaysEnabled": companyDaysEnabled,
                                            "companyHoursEnabled": companyHoursEnabled,
                                            "companyCity": companyCity,
                                            "companyState": companyState,
                                            "companyZip": companyZip]
        
        let httpRequest = HTTPRequests()
        httpRequest.request(endpoint: "/signup.php", dataModel: SuccessResponse.self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let successResponse):
                    print(successResponse.reason)
                    success(email, password)
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
            }
            
            self?.removeSpinner()
        }
    }
    
        func loginUser(email: String, password: String, success: (() -> Void)?) {
        
            let httpRequest = HTTPRequests()
            let parameters: [String: Any] = ["email": email, "password": password]
            httpRequest.request(endpoint: "/login.php", dataModel: CustomerModel.self, parameters: parameters) { [weak self] (result) in
                
                switch result {
                    case .success(let customer):
                        
                        // Go to container view controller
                        if let containerViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.container.rawValue) as? ContainerViewController  {
                            
                            // Get non optionals from CustomerModel instance
                            let dateJoinedDate = customer.dateJoinedDate
                            let id = Int32(customer.id)
                            let customerType = customer.customerType
                            let email = customer.email
                            let firstName = customer.firstName
                            let isPaying = customer.isPaying
                            let lastName = customer.lastName
                            let phoneNumber = customer.phoneNumber
                            let wantsSms = customer.wantsSms
                            let username = customer.username
                            let lastLoginDate = customer.lastLoginDate
                            
                            // If there are no customer CoreData objects, save the new customer object
                            let customerCount = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.customer.rawValue)
                            if customerCount == 0 { // New users to the app logging in for first time
                                print("New user to the app!")
                                guard let coreDataCustomerObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.customer.rawValue, into: PersistenceService.context) as? Customer else { return }
                                
                                coreDataCustomerObject.addCustomer(customerType: customerType, dateJoined: dateJoinedDate, email: email, firstName: firstName, id: id, isPaying: isPaying, lastName: lastName, phoneNumber: phoneNumber, wantsSms: wantsSms, password: password, username: username, lastLogin: lastLoginDate, companies: nil)
                                
                                PersistenceService.saveContext()
                                
                            } else if (customerCount > 0) && (email != self?.coreDataCustomerEmail) {
                                // If the email that was typed into the email text field matches the email attribute value
                                // of the customer object we have stored in CoreData, do nothing. Otherwise,
                                // delete ALL data from CoreData and update the customer object
                                
                                print("Existing user with new login information!")
                                // Delete all CoreData data from previous logins
                                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.customer.rawValue)
                                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.company.rawValue)
                                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.lead.rawValue)
                                
                                // Create new customer object in CoreData for new login information
                                guard let coreDataCustomerObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.customer.rawValue, into: PersistenceService.context) as? Customer else { return }
                                
                                coreDataCustomerObject.addCustomer(customerType: customerType, dateJoined: dateJoinedDate, email: email, firstName: firstName, id: id, isPaying: isPaying, lastName: lastName, phoneNumber: phoneNumber, wantsSms: wantsSms, password: password, username: username, lastLogin: lastLoginDate, companies: nil)
                                
                                PersistenceService.saveContext()
                                
                            }
                            
                            containerViewController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
                            self?.present(containerViewController, animated: true, completion: nil)
                            
                            guard let unwrappedSuccess = success else { return }
                            unwrappedSuccess()
                        }
                    
                    case .failure(let error):
                        // Set text for pop up ok view controller
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                    
                }
                
            }
        
    }
    
    // MARK: Actions
    @IBAction func addCompanyButtonTapped(_ sender: Any) {
        
        let didSelectHours = AddCompanyHelper.optionIsSelected(options: self.hoursOfTheDayAM + self.hoursOfTheDayPM)
        if didSelectHours {
            
            if self.userIsSigningUp {
                // Make POST request with customer data to API
                self.showSpinner(for: view, textForLabel: "Signing Up")
                let selectedOptionsString = AddCompanyHelper.getSelectedOptions(options: self.hoursOfTheDayAM + self.hoursOfTheDayPM)
                self.company?.hoursOfTheDayEnabled = selectedOptionsString
                
                self.signupUser {
                    [weak self] (email, password) in
                    self?.loginUser(email: email, password: password, success: {
                        [weak self] in
                        
                        // Add username and password to keychain if user wants to
                        let title = "Add To Keychain"
                        let body = "Would you like to securely add your username and password to Keychain for easier login?"
                        guard let popUpActionViewController = self?.alertService.popUp(title: title, body: body, buttonTitle: "Yes", completion: {
                            KeychainWrapper.standard.set(email, forKey: Defaults.KeychainKeys.email.rawValue)
                            KeychainWrapper.standard.set(password, forKey: Defaults.KeychainKeys.password.rawValue)
                        }) else { return }
                        self?.present(popUpActionViewController, animated: true, completion: nil)
                        
                    })
                }
            } else {
                // Navigate to success screen once the company has been sucessfully added
                if let successViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController {
                    
                    successViewController.titleLabelText = "Company Added!"
                    successViewController.subtitleText = "The company has been successfully added."
                    self.present(successViewController, animated: true, completion: nil)
                    
                }
            }
            
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select An Hour", body: "Please select at least one hour.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    
    }
    
}

extension AddCompanyHoursEnabledViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Need two sections for the table view: one for AM and one for PM hours
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hoursOfTheDayAM.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let section = indexPath.section
        switch section {
            case 0: // AM Hours Section
                let enableOption = self.hoursOfTheDayAM[indexPath.row] // Get the EnableOption object
                cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
            case 1: // PM Hours Section
                let enableOption = self.hoursOfTheDayPM[indexPath.row] // Get the EnableOption object
                cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
            default:
                return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        
        let selected = cell.toggleCheckMark(cell: cell)
        
        if indexPath.section == 0 { // For the AM hours array
           self.hoursOfTheDayAM[indexPath.row].selected = selected // Set the EnableOption object attribute 'selected' to false or true if it was selected
        } else { // For the PM hours array
            self.hoursOfTheDayPM[indexPath.row].selected = selected
        }
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0: // AM hours section
                return "AM Hours"
            case 1: // PM hours section
                return "PM Hours"
            default:
                return ""
        }
        
    }
    
}
