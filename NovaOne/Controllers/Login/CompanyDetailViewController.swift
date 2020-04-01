//
//  PropertyDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class CompanyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var propertyDetailTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: NovaOneView!
    var company: Any?
    var companyDetailCells: [[String: Any]] = [[:]]
    let alertService = AlertService()
    
    // MARK: Methods
    func setup() {
        self.propertyDetailTableView.delegate = self
        self.propertyDetailTableView.dataSource = self
        
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
    }
    
    func setupCompanyCellsAndTitle(name: String, phoneNumber: String, email: String, address: String) {
        // Sets up the cell properties for each company cell and title for the view
        // Title
        self.titleLabel.text = address
        
        // Cells
        let nameCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.locationBlue.rawValue) as Any, "cellTitle": "Name", "cellTitleValue": name, "canUpdateValue": true]
        let addressCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.locationBlue.rawValue) as Any, "cellTitle": "Address", "cellTitleValue": address, "canUpdateValue": true]
        let phoneNumberCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.callBlue.rawValue) as Any, "cellTitle": "Phone", "cellTitleValue": phoneNumber, "canUpdateValue": true]
        let emailCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.emailBlue.rawValue) as Any, "cellTitle": "Email", "cellTitleValue": email, "canUpdateValue": true]
        let daysOfTheWeekCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.calendarBlue.rawValue) as Any, "cellTitle": "Showing Days", "cellTitleValue": "", "canUpdateValue": true]
        let hoursOfTheDayCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.calendarBlue.rawValue) as Any, "cellTitle": "Showing Hours", "cellTitleValue": "", "canUpdateValue": true]
        
        self.companyDetailCells = [nameCell, addressCell, phoneNumberCell, emailCell, daysOfTheWeekCell, hoursOfTheDayCell]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
        // Setup table cell based on which object was passed to self.company
        if let company = self.company as? Company { // self.company is a CoreData object
            guard
                let name = company.name,
                let phoneNumber = company.phoneNumber,
                let email = company.email,
                let address = company.shortenedAddress
            else { return }
            
            // Plug into setupCompanyCells method
            self.setupCompanyCellsAndTitle(name: name, phoneNumber: phoneNumber, email: email, address: address)
            
        } else if let company = self.company as? CompanyModel { // self.company is a CompanyModel object
            guard
                let name = company.name,
                let phoneNumber = company.phoneNumber,
                let email = company.email
            else { return }
            let address = company.shortenedAddress
            
            // Plug into setupCompanyCells method
            self.setupCompanyCellsAndTitle(name: name, phoneNumber: phoneNumber, email: email, address: address)
        }
        
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete Company"
        let body = "Are you sure you want to delete the company?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle) {
            print("Delete button tapped!")
        }
        self.present(popUpViewController, animated: true, completion: nil)
    }
    
    

}

extension CompanyDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companyDetailCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let companydetailCell = self.companyDetailCells[indexPath.row]
        
        cell.setup(cellIcon: companydetailCell["cellIcon"] as! UIImage, cellTitle: companydetailCell["cellTitle"] as! String, cellTitleValue: companydetailCell["cellTitleValue"] as! String, canUpdateValue: companydetailCell["canUpdateValue"] as! Bool)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get propertyDetail object based on which row the user taps on
        guard let cellTitle = self.companyDetailCells[indexPath.row]["cellTitle"] as? String else { return }
        
        //Get update view controller based on which cell the user clicked on
        switch cellTitle {
            case "Address":
                if let updatePropertyAddressViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyAddress.rawValue) as? UpdatePropertyAddressViewController {
                    self.present(updatePropertyAddressViewController, animated: true, completion: nil)
            }
            case "Phone":
                if let updatePropertyPhoneViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyPhone.rawValue) as? UpdatePropertyPhoneViewController {
                    self.present(updatePropertyPhoneViewController, animated: true, completion: nil)
                }
        case "Name":
            if let updatePropertyNameViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyName.rawValue) as? UpdatePropertyNameViewController {
                self.present(updatePropertyNameViewController, animated: true, completion: nil)
            }
        case "Email":
            if let updatePropertyEmailViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyEmail.rawValue) as? UpdatePropertyEmailViewController {
                self.present(updatePropertyEmailViewController, animated: true, completion: nil)
            }
        case "Showing Days":
            if let updateCompanyDaysEnabledViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updateCompanyDaysEnabled.rawValue) as? UpdateCompanyDaysEnabledViewController {
                self.present(updateCompanyDaysEnabledViewController, animated: true, completion: nil)
            }
        case "Showing Hours":
            if let updateCompanyHoursEnabledViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updateCompanyHoursEnabled.rawValue) as? UpdateCompanyHoursEnabledViewController {
                self.present(updateCompanyHoursEnabledViewController, animated: true, completion: nil)
            }
            default:
                print("No cases matched")
        }
        
    }
    
}
