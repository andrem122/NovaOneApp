//
//  CompanyDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SafariServices

class CompanyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    
    // MARK: Properties
    var objectDetailItems: [ObjectDetailItem] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var topView: NovaOneView!
    var company: Company?
    let alertService = AlertService()
    
    // MARK: Methods
    func setupTableView() {
        self.objectDetailTableView.rowHeight = 44
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
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
        self.titleLabel.text = name
        
        // Cells
        let nameItem = ObjectDetailItem(title: "Name", titleValue: name)
        let addressItem = ObjectDetailItem(title: "Address", titleValue: address)
        let phoneNumberItem = ObjectDetailItem(title: "Phone", titleValue: phoneNumber)
        let emailItem = ObjectDetailItem(title: "Email", titleValue: email)
        let appointmentLinkItem = ObjectDetailItem(title: "Appointment Link", titleValue: "")
        let daysOfTheWeekItem = ObjectDetailItem(title: "Showing Days", titleValue: "")
        let hoursOfTheDayItem = ObjectDetailItem(title: "Showing Hours", titleValue: "")
        
        self.objectDetailItems = [nameItem,
                                  addressItem,
                                  phoneNumberItem,
                                  emailItem,
                                  appointmentLinkItem,
                                  daysOfTheWeekItem,
                                  hoursOfTheDayItem]
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
        guard
            let name = company?.name,
            let phoneNumber = company?.phoneNumber,
            let email = company?.email,
            let address = company?.shortenedAddress
        else { return }
        
        // Plug into setupCompanyCells method
        self.setupCompanyCellsAndTitle(name: name, phoneNumber: phoneNumber, email: email, address: address)
        
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete Company"
        let body = "Are you sure you want to delete the company?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
            [weak self] in
            // Delete the company from CoreData
            
            // Delete the company from the database
            
            // Navigate back to the companies view
            guard let companiesViewController = self?.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.companies.rawValue) else { return }
            self?.present(companiesViewController, animated: true, completion: nil)
        }, cancelHandler: {
            print("Action canceled")
        })
        self.present(popUpViewController, animated: true, completion: nil)
    }

}

extension CompanyDetailViewController {
    
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
        let cellTitle = self.objectDetailItems[indexPath.row].title
        
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
                
                updateCompanyDaysEnabledViewController.company = company
                self.navigationController?.pushViewController(updateCompanyDaysEnabledViewController, animated: true)
                
            }
        case "Showing Hours":
            if let updateCompanyHoursEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyHoursEnabled.rawValue) as? UpdateCompanyHoursEnabledViewController {
                
                updateCompanyHoursEnabledViewController.company = self.company
                self.navigationController?.pushViewController(updateCompanyHoursEnabledViewController, animated: true)
                
            }
        case "Appointment Link":
            guard
                let companyId = self.company?.id
            else { return }
            UIPasteboard.general.string = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
            
            // Show popup confirming that text has been copied
            let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "Appointment link has been copied to clipboard successfully.")
            self.present(popUpOkViewController, animated: true, completion: nil)
            default:
                print("No cases matched")
        }
        
    }
    
}
