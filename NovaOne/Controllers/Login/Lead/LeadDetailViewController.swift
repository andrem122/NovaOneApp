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
        let phoneNumberItem = ObjectDetailItem(title: "Phone", titleValue: phoneNumber)
        let emailItem = ObjectDetailItem(title: "Email", titleValue: email)
        let contactedItem = ObjectDetailItem(title: "Contacted", titleValue: contactedLead)
        let addressItem = ObjectDetailItem(title: "Company", titleValue: companyName)
        let dateOfInquiryItem = ObjectDetailItem(title: "Date Of Inquiry", titleValue: dateOfInquiry)
        
        self.titleLabel.text = name
        self.objectDetailItems = [
            phoneNumberItem,
            emailItem,
            contactedItem,
            dateOfInquiryItem,
            addressItem]
        
        guard let customerType = self.customer?.customerType else { return }
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            guard let renterBrand = self.lead?.renterBrand else { return }
            let renterBrandItem = ObjectDetailItem(title: "Renter Brand", titleValue: renterBrand)
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
    }

}

