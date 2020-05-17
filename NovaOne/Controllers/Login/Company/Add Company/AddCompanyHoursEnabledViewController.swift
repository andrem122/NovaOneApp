//
//  AddCompanyHoursEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyHoursEnabledViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addCompanyEnabledHoursTableView: UITableView!
    @IBOutlet weak var appointmentHoursButton: NovaOneButton!
    let alertService = AlertService()
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
    
    // MARK: Actions
    @IBAction func addCompanyButtonTapped(_ sender: Any) {
        
        let didSelectHours = AddCompanyHelper.optionIsSelected(options: self.hoursOfTheDayAM + self.hoursOfTheDayPM)
        if didSelectHours {
            
            if self.userIsSigningUp {
                // Make POST request with customer data to API
                let selectedOptionsString = AddCompanyHelper.getSelectedOptions(options: self.hoursOfTheDayAM + self.hoursOfTheDayPM)
                self.company?.hoursOfTheDayEnabled = selectedOptionsString
                print(self.customer as Any)
                print(self.company as Any)
                
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
                    case .success(let success):
                        print(success.reason)
                    case .failure(let error):
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                    }
                }
                // Make Login POST request once POST request with customer data is complete
                
                // Once login POST request to API is complete, navigate to home screen if user is signing up
//                if let homeTabBarController = self.storyboard?.instantiateViewController(identifier: Defaults.TabBarControllerIdentifiers.home.rawValue) as? HomeTabBarController {
//                    self.present(homeTabBarController, animated: true, completion: nil)
//                }
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
