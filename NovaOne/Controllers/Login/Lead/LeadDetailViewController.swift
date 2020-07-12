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
        let format = "MMM d, yyyy | h:mm a"
        let sentTextDate = lead.sentTextDate != nil ? DateHelper.createString(from: lead.sentTextDate!, format: format) : "Not Texted"
        let sentEmailDate = lead.sentEmailDate != nil ? DateHelper.createString(from: lead.sentEmailDate!, format: format) : "Not Emailed"
        let dateOfInquiry = DateHelper.createString(from: dateOfInquiryDate, format: format)
        
        // Set default values for optional types
        let phoneNumber = lead.phoneNumber != nil ? lead.phoneNumber! : "No phone"
        let unwrappedEmail = lead.email != nil ? lead.email! : "" // lead.email! returns an empty string even if it is not nil
        let email = unwrappedEmail.isEmpty ? "No email" : unwrappedEmail
        
        // Create dictionaries for cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
        let companyNameItem = ObjectDetailItem(titleValue: companyName, titleItem: .companyName)
        let dateOfInquiryItem = ObjectDetailItem(titleValue: dateOfInquiry, titleItem: .dateOfInquiry)
        let sentTextDateItem = ObjectDetailItem(titleValue: sentTextDate, titleItem: .sentTextDate)
        let sentEmailDateItem = ObjectDetailItem(titleValue: sentEmailDate, titleItem: .sentEmailDate)
        
        self.titleLabel.text = name
        self.objectDetailItems = [
            nameItem,
            phoneNumberItem,
            emailItem,
            dateOfInquiryItem,
            companyNameItem,
            sentTextDateItem,
            sentEmailDateItem]
        
        let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
        guard let customerType = customer?.customerType else { return }
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
        let updateLeadStoryboard = UIStoryboard(name: Defaults.StoryBoards.updateLead.rawValue, bundle: .main)
        
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        switch titleItem {
            case .name:
                guard let updateLeadNameViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadName.rawValue) as? UpdateLeadNameViewController else { return }
                
                updateLeadNameViewController.updateObject = self.lead
                updateLeadNameViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadNameViewController, animated: true)
            case .email:
                guard let updateLeadEmailViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadEmail.rawValue) as? UpdateLeadEmailViewController else { return }
                
                updateLeadEmailViewController.updateObject = self.lead
                updateLeadEmailViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadEmailViewController, animated: true)
            case .phoneNumber:
                guard let updateLeadPhoneViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadPhone.rawValue) as? UpdateLeadPhoneViewController else { return }
                
                updateLeadPhoneViewController.updateObject = self.lead
                updateLeadPhoneViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadPhoneViewController, animated: true)
            case .dateOfInquiry:
                guard let updateLeadDateOfInquiryViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadDateOfInquiry.rawValue) as? UpdateLeadDateOfInquiryViewController else { return }
                
                updateLeadDateOfInquiryViewController.updateObject = self.lead
                updateLeadDateOfInquiryViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadDateOfInquiryViewController, animated: true)
            case .sentTextDate:
                guard let updateLeadSentTextDateViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadSentTextDate.rawValue) as? UpdateLeadSentTextDateViewController else { return }
                
                updateLeadSentTextDateViewController.updateObject = self.lead
                updateLeadSentTextDateViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadSentTextDateViewController, animated: true)
            case .sentEmailDate:
                guard let updateLeadSentEmailDateViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadSentEmailDate.rawValue) as? UpdateLeadSentEmailDateViewController else { return }
                
                updateLeadSentEmailDateViewController.updateObject = self.lead
                updateLeadSentEmailDateViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadSentEmailDateViewController, animated: true)
            case .companyName:
                guard let updateLeadCompanyViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadCompany.rawValue) as? UpdateLeadCompanyViewController else { return }
                
                updateLeadCompanyViewController.updateObject = self.lead
                updateLeadCompanyViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadCompanyViewController, animated: true)
            case .renterBrand:
                guard let updateLeadRenterViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadRenterBrand.rawValue) as? UpdateLeadRenterBrandViewController else { return }
                
                updateLeadRenterViewController.updateObject = self.lead
                updateLeadRenterViewController.previousViewController = self
                
                self.navigationController?.pushViewController(updateLeadRenterViewController, animated: true)
            default:
                print("No cases matched")
        }
    }

}

