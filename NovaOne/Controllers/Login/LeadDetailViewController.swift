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
    var objectDetailCells: [[String : String]] = []
    var lead: LeadModel?
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
        // Set cells up for the table view
        
        guard
            let lead = self.lead
        else { return }
        let name = lead.name
        let renterBrand = lead.renterBrand
        
        // Set default values for optional types
        let phoneNumber = lead.phoneNumber != nil ? lead.phoneNumber! : "No phone"
        let unwrappedEmail = lead.email != nil ? lead.email! : "" // lead.email! returns an empty string even if it is not nil
        let email = unwrappedEmail.isEmpty ? "No email" : unwrappedEmail
        
        let dateOfInquiry: String = self.convert(lead: lead.dateOfInquiryDate)
        let companyName = lead.companyName
        
        // Create dictionaries for cells
        let phoneNumberCell = ["cellTitle": "Phone", "cellTitleValue": phoneNumber]
        let emailCell = ["cellTitle": "Email", "cellTitleValue": email]
        let renterBrandCell = ["cellTitle": "Renter Brand", "cellTitleValue": renterBrand]
        let addressCell = ["cellTitle": "Company", "cellTitleValue": companyName]
        let dateOfInquiryCell = ["cellTitle": "Date Of Inquiry", "cellTitleValue": dateOfInquiry]
        
        self.titleLabel.text = name
        self.objectDetailCells = [
            phoneNumberCell,
            emailCell,
            renterBrandCell,
            dateOfInquiryCell,
            addressCell]
        
        self.objectDetailTableView.reloadData()
    }

}

extension LeadDetailViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailCell = self.objectDetailCells[indexPath.row]
        
        cell.setup(cellTitle: objectDetailCell["cellTitle"]!, cellTitleValue: objectDetailCell["cellTitleValue"]!)
        
        return cell
    }

}

