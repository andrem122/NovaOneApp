//
//  LeadsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LeadsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var leadsTableView: UITableView!
    var customer: CustomerModel?
    var leads: [LeadModel] = []
        
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.leadsTableView.delegate = self
        self.leadsTableView.dataSource = self
    }
    
    func setUp() {
        // Set seperator color for table view
        self.leadsTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
    }

}

extension LeadsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leads.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let lead: LeadModel = self.leads[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cell = tableView.dequeueReusableCell(withIdentifier: "novaOneTableCell") as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Unwrap values from object and set up cell text
        guard
            let leadName = lead.name,
            let address = lead.address,
            let leadBrand = lead.renterBrand
        else { return cell }
        let dateOfInquiryDate = lead.dateOfInquiryDate
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let dateContacted: String = dateFormatter.string(from: dateOfInquiryDate)
        
        
        cell.setup(title: leadName, subTitleOne: address, subTitleTwo: leadBrand, subTitleThree: dateContacted)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get lead object based on which row the user taps on
        let lead = self.leads[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let leadDetailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.leadDetail.rawValue) as? LeadDetailViewController {
            
            leadDetailViewController.lead = lead
            leadDetailViewController.modalPresentationStyle = .automatic
            self.present(leadDetailViewController, animated: true, completion: nil)
            
        }
    }

}
