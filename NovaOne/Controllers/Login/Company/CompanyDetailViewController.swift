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
    
    func setupCompanyCellsAndTitle() {
        // Sets up the cell properties for each company cell and title for the view
        // Title
        print("Setting up company cells and title")
        guard
            let company = self.company,
            let name = company.name,
            let phoneNumber = company.phoneNumber,
            let email = company.email,
            let address = company.shortenedAddress
        else { return }
        
        print("COMPANY ADDRESS: \(address)")
        
        self.titleLabel.text = name
        let autoRespondNumber = company.autoRespondNumber != nil ? company.autoRespondNumber! : "No Auto Respond"
        
        // Cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let addressItem = ObjectDetailItem(titleValue: address, titleItem: .address)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
        let appointmentLinkItem = ObjectDetailItem(titleValue: "", titleItem: .appointmentLink)
        let daysOfTheWeekItem = ObjectDetailItem(titleValue: "", titleItem: .showingDays)
        let hoursOfTheDayItem = ObjectDetailItem(titleValue: "", titleItem: .showingHours)
        let autoRespondNumberItem = ObjectDetailItem(titleValue: autoRespondNumber, titleItem: .autoRespondNumber)
        let autoRespondTextItem = ObjectDetailItem(titleValue: "", titleItem: .autoRespondText)
        
        self.objectDetailItems = [nameItem,
                                  addressItem,
                                  phoneNumberItem,
                                  emailItem,
                                  appointmentLinkItem,
                                  daysOfTheWeekItem,
                                  hoursOfTheDayItem,
                                  autoRespondNumberItem,
                                  autoRespondTextItem]
    }
    
    func setupNavigationBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupTopView()
        self.setupNavigationBackButton()
        self.setupCompanyCellsAndTitle()
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
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        
        // Get update view controller based on which cell the user clicked on
        switch titleItem {
            
            case .address:
                if let updateCompanyAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAddress.rawValue) as? UpdateCompanyAddressViewController {
                    
                    updateCompanyAddressViewController.updateObject = self.company
                    updateCompanyAddressViewController.detailViewController = self
                    
                    self.navigationController?.pushViewController(updateCompanyAddressViewController, animated: true)
                    
                }
                    
                case .phoneNumber:
                    if let updateCompanyPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyPhone.rawValue) as? UpdateCompanyPhoneViewController {
                        
                        updateCompanyPhoneViewController.updateObject = self.company
                        updateCompanyPhoneViewController.detailViewController = self
                        
                        self.navigationController?.pushViewController(updateCompanyPhoneViewController, animated: true)
                        
                    }
                    
                case .name:
                    if let updateCompanyNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyName.rawValue) as? UpdateCompanyNameViewController {
                        
                        updateCompanyNameViewController.updateObject = self.company
                        updateCompanyNameViewController.detailViewController = self
                        
                        self.navigationController?.pushViewController(updateCompanyNameViewController, animated: true)
                        
                    }
                    
                case .email:
                    if let updateCompanyEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyEmail.rawValue) as? UpdateCompanyEmailViewController {
                        
                        updateCompanyEmailViewController.updateObject = self.company
                        updateCompanyEmailViewController.detailViewController = self
                        
                        self.navigationController?.pushViewController(updateCompanyEmailViewController, animated: true)
                        
                    }
                    
                case .showingDays:
                    if let updateCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyDaysEnabled.rawValue) as? UpdateCompanyDaysEnabledViewController {
                        
                        updateCompanyDaysEnabledViewController.company = company
                        updateCompanyDaysEnabledViewController.updateObject = self.company
                        updateCompanyDaysEnabledViewController.detailViewController = self
                        
                        self.navigationController?.pushViewController(updateCompanyDaysEnabledViewController, animated: true)
                        
                    }
                    
                case .showingHours:
                    if let updateCompanyHoursEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyHoursEnabled.rawValue) as? UpdateCompanyHoursEnabledViewController {
                        
                        updateCompanyHoursEnabledViewController.updateObject = self.company
                        updateCompanyHoursEnabledViewController.detailViewController = self
                        updateCompanyHoursEnabledViewController.company = self.company
                        
                        self.navigationController?.pushViewController(updateCompanyHoursEnabledViewController, animated: true)
                        
                    }
                    
                case .appointmentLink:
                    guard
                        let companyId = self.company?.id
                    else { return }
                    UIPasteboard.general.string = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
                    
                    // Show popup confirming that text has been copied
                    let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "Appointment link has been copied to clipboard successfully.")
                    self.present(popUpOkViewController, animated: true, completion: nil)
                    
                case .autoRespondNumber:
                    guard
                        let autoRespondNumber = self.company?.autoRespondNumber
                    else { return }
                    UIPasteboard.general.string = autoRespondNumber
                    
                    // Show popup confirming that text has been copied
                    let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "Auto respond number has been copied to clipboard successfully.")
                    self.present(popUpOkViewController, animated: true, completion: nil)
                    
                case .autoRespondText:
                    if let updateCompanyAutoRespondTextViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAutoRespondText.rawValue) as? UpdateCompanyAutoRespondTextViewController {
                        
                        guard let company = self.company else { return }
                        let autoRespondText = company.autoRespondText != nil ? company.autoRespondText! : "Update auto respond text..."
                        
                        updateCompanyAutoRespondTextViewController.updateObject = self.company
                        updateCompanyAutoRespondTextViewController.detailViewController = self
                        updateCompanyAutoRespondTextViewController.autoRespondText = autoRespondText
                        
                        self.navigationController?.pushViewController(updateCompanyAutoRespondTextViewController, animated: true)
                        
                    }
                
                default:
                print("No cases matched")
            
        }
        
    }
    
}
