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
        self.getLeads()
    }
    
    func setUp() {
        
        // Set seperator color for table view
        self.leadsTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        
    }
    
    // Get's appointments from the database
    func getLeads() {
        
        let httpRequest = HTTPRequests()
        guard
            let customerUserId = self.customer?.id,
            let email = self.customer?.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            print("Failed to obtain variables for POST request")
            return
        }
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/leads.php",
                            dataModel: [LeadModel(id: 1)], // Must have one non optional value in our object otherwise JSONDecoder will be able to decode the ANY json response into an appointment object because all fields are optional
                            parameters: parameters) { (result) in
                                
                                switch result {
                                    
                                    case .success(let leads):
                                        self.leads = leads
                                        self.leadsTableView.reloadData() // Reload table to show data pulled from the database
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    
                                }
                                
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTouched(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Enumerations

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
            let leadBrand = lead.renterBrand,
            let dateOfInquiry = lead.dateOfInquiry
        else { return cell }
        let dateOfInquiryDate = lead.date(from: dateOfInquiry)
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let dateContacted: String = dateFormatter.string(from: dateOfInquiryDate)
        
        
        cell.setup(title: leadName, subTitleOne: address, subTitleTwo: leadBrand, subTitleThree: dateContacted)
        
        return cell
    }

}
