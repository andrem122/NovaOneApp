//
//  LeadsDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LeadDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailItems: [ObjectDetailItem] = []
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    var lead: Lead?
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: NovaOneView!
    
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
        self.objectDetailTableView.rowHeight = 44;
    }
    
    func convert(lead date: Date) -> String {
        // Convert date object to a string in a date format
        
        // Get dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let formattedDate: String = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Set cell values for the table view
        
        guard
            let lead = self.lead,
            let name = lead.name,
            let companyName = lead.companyName,
            let dateOfInquiryDate = lead.dateOfInquiry
        else { return }
        let contactedLead = lead.sentTextDate != nil || lead.sentEmailDate != nil ? "Contacted" : "Not Contacted"
        
        // Set default values for optional types
        let phoneNumber = lead.phoneNumber != nil ? lead.phoneNumber! : "No phone"
        let unwrappedEmail = lead.email != nil ? lead.email! : "" // lead.email! returns an empty string even if it is not nil
        let email = unwrappedEmail.isEmpty ? "No email" : unwrappedEmail
        
        let dateOfInquiry: String = self.convert(lead: dateOfInquiryDate)
        
        // Create dictionaries for cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
        let contactedItem = ObjectDetailItem(titleValue: contactedLead, titleItem: .contacted)
        let companyNameItem = ObjectDetailItem(titleValue: companyName, titleItem: .companyName)
        let dateOfInquiryItem = ObjectDetailItem(titleValue: dateOfInquiry, titleItem: .dateOfInquiry)
        
        self.titleLabel.text = name
        self.objectDetailItems = [
            nameItem,
            phoneNumberItem,
            emailItem,
            contactedItem,
            dateOfInquiryItem,
            companyNameItem]
        
        guard let customerType = self.customer?.customerType else { return }
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            guard let renterBrand = self.lead?.renterBrand else { return }
            let renterBrandItem = ObjectDetailItem(titleValue: renterBrand, titleItem: .renterBrand)
            self.objectDetailItems.append(renterBrandItem)
        }
        
    }

}

extension LeadDetailViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        switch titleItem {
            case .name:
                guard let updateLeadNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadName.rawValue) as? UpdateLeadNameViewController else { return }
                
                updateLeadNameViewController.updateObject = self.lead
                updateLeadNameViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadNameViewController, animated: true)
            case .email:
                guard let updateLeadEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadEmail.rawValue) as? UpdateLeadEmailViewController else { return }
                
                updateLeadEmailViewController.updateObject = self.lead
                updateLeadEmailViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadEmailViewController, animated: true)
            case .phoneNumber:
                guard let updateLeadPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadPhone.rawValue) as? UpdateLeadPhoneViewController else { return }
                
                updateLeadPhoneViewController.updateObject = self.lead
                updateLeadPhoneViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadPhoneViewController, animated: true)
            case .contacted:
                guard let updateLeadContactedViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadContacted.rawValue) as? UpdateLeadContactedViewController else { return }
                
                updateLeadContactedViewController.updateObject = self.lead
                updateLeadContactedViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadContactedViewController, animated: true)
            case .dateOfInquiry:
                guard let updateLeadDateOfInquiryViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadDateOfInquiry.rawValue) as? UpdateLeadDateOfInquiryViewController else { return }
                
                updateLeadDateOfInquiryViewController.updateObject = self.lead
                updateLeadDateOfInquiryViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadDateOfInquiryViewController, animated: true)
            case .companyName:
                guard let updateLeadCompanyViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadCompany.rawValue) as? UpdateLeadCompanyViewController else { return }
                
                updateLeadCompanyViewController.updateObject = self.lead
                updateLeadCompanyViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadCompanyViewController, animated: true)
            default:
                print("No cases matched")
        }
    }

}

