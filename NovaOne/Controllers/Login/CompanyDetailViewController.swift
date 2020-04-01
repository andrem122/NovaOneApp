//
//  CompanyDetailViewController.swift
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
    func setupTableView() {
        self.propertyDetailTableView.delegate = self
        self.propertyDetailTableView.dataSource = self
    }
    
    func setupTopView() {
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
        let nameCell: [String: String] = ["cellTitle": "Name", "cellTitleValue": name]
        let addressCell: [String: String] = ["cellTitle": "Address", "cellTitleValue": address]
        let phoneNumberCell: [String: String] = ["cellTitle": "Phone", "cellTitleValue": phoneNumber]
        let emailCell: [String: String] = ["cellTitle": "Email", "cellTitleValue": email]
        let daysOfTheWeekCell: [String: String] = ["cellTitle": "Showing Days", "cellTitleValue": ""]
        let hoursOfTheDayCell: [String: String] = ["cellTitle": "Showing Hours", "cellTitleValue": ""]
        
        self.companyDetailCells = [nameCell, addressCell, phoneNumberCell, emailCell, daysOfTheWeekCell, hoursOfTheDayCell]
    }
    
    func setupNavigationBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupTopView()
        self.setupNavigationBackButton()
        
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
        
        cell.setup(cellTitle: companydetailCell["cellTitle"] as! String, cellTitleValue: companydetailCell["cellTitleValue"] as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get company title based on which row the user taps on
        guard let cellTitle = self.companyDetailCells[indexPath.row]["cellTitle"] as? String else { return }
        
        // Get update view controller based on which cell the user clicked on
        switch cellTitle {
            case "Address":
                if let updateCompanyAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAddress.rawValue) as? UpdateCompanyAddressViewController {
                    
                    self.navigationController?.pushViewController(updateCompanyAddressViewController, animated: true)
                    
            }
            case "Phone":
                if let updateCompanyPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyPhone.rawValue) as? UpdateCompanyPhoneViewController {
                    
                    self.navigationController?.pushViewController(updateCompanyPhoneViewController, animated: true)
                    
                }
        case "Name":
            if let updateCompanyNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyName.rawValue) as? UpdateCompanyNameViewController {
                
                self.navigationController?.pushViewController(updateCompanyNameViewController, animated: true)
                
            }
        case "Email":
            if let updateCompanyEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyEmail.rawValue) as? UpdateCompanyEmailViewController {
                
                self.navigationController?.pushViewController(updateCompanyEmailViewController, animated: true)
                
            }
        case "Showing Days":
            if let updateCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyDaysEnabled.rawValue) as? UpdateCompanyDaysEnabledViewController {
                
                self.navigationController?.pushViewController(updateCompanyDaysEnabledViewController, animated: true)
                
            }
        case "Showing Hours":
            if let updateCompanyHoursEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyHoursEnabled.rawValue) as? UpdateCompanyHoursEnabledViewController {
                
                self.navigationController?.pushViewController(updateCompanyHoursEnabledViewController, animated: true)
                
            }
            default:
                print("No cases matched")
        }
        
    }
    
}
