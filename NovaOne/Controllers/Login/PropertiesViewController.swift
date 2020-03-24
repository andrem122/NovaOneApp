//
//  PropertiesViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class PropertiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var propertiesTableView: UITableView!
    var companies: [Company] = []
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.getCompanies()
    }
    
    func setup() {
        self.propertiesTableView.delegate = self
        self.propertiesTableView.dataSource = self
    }
    
    func getCompanies() {
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            print("Failed to obtain variables for POST request")
            return
        }
        
        let parameters: [String: Any] = ["customerUserId": customer.id as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/properties.php", dataModel: [Company(id: 1)], parameters: parameters) { (result) in
                switch result {
                    
                    case .success(let companies):
                        self.companies = companies
                        self.propertiesTableView.reloadData() // Reload table to show data pulled from the database
                    case .failure(let error):
                        print(error.localizedDescription)
                    
                }
        }
    }

}

extension PropertiesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property: Company = self.companies[indexPath.row] // Get the property object based on the row number each cell is in
        let cellIdentifier: String = Defaults.CellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Pass in appointment object to set up cell properties (address, city, etc.)
        let address = property.shortenedAddress
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let createdTimeDate: Date = property.createdDate
        let createdTime: String = dateFormatter.string(from: createdTimeDate)
        
        cell.setup(title: address, subTitleOne: "Fort Pierce, FL", subTitleTwo: "34950", subTitleThree: createdTime)
        
        return cell
    }
    
    // Function gets called every time a row in the table gets tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get appointment object based on which row the user taps on
        let property = self.companies[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let propertyDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.propertyDetail.rawValue) as? PropertyDetailViewController {
            propertyDetailViewController.property = property
            self.navigationController?.pushViewController(propertyDetailViewController, animated: true)
        }
    }
    
}