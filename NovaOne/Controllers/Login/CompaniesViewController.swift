//
//  PropertiesViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class CompaniesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var companiesTableView: UITableView!
    var companies: [CompanyModel] = []
    var coreDataCompanies: [Any]?
    var customerHasCompanies: Bool = PersistenceService.customerHasCompanies()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.fetchCoreDataCompanies()
    }
    
    func setup() {
        self.companiesTableView.delegate = self
        self.companiesTableView.dataSource = self
    }
    
    func fetchCoreDataCompanies() {
        // Get companies for customer from Coredata IF they exist else get them from the database
        
        if self.customerHasCompanies {
            print("Customer has companies")
            guard let coreDataCompanies: [Any] = PersistenceService.fetchCustomerCompanies() else { return }
            self.coreDataCompanies = coreDataCompanies
            
        } else {
            // No CoreData objects, so get companies from the NovaOne database
            self.refreshCompanies()
        }
    }
    
    func refreshCompanies() {
        // Gets the companies a user has from the NovaOne database via an HTTP Request
        // and saves to CoreData
        
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
        
        httpRequest.request(endpoint: "/properties.php", dataModel: [CompanyModel(id: 1)], parameters: parameters) { (result) in
                switch result {
                    
                    case .success(let companies):
                        self.companies = companies
                        
                        // Save the companies in CoreData
                        guard let entity = NSEntityDescription.entity(forEntityName: "Company", in: PersistenceService.context) else { return }
                        
                        for company in companies {
                            if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
                                coreDataCompany.address = company.address
                                coreDataCompany.created = company.createdDate
                                coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
                                coreDataCompany.email = company.email
                                coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
                                coreDataCompany.id = Int32(company.id)
                                coreDataCompany.name = company.name
                                coreDataCompany.phoneNumber = company.phoneNumber
                                coreDataCompany.shortenedAddress = company.shortenedAddress
                                coreDataCompany.customer = PersistenceService.fetchCustomerEntity()
                            }
                        }
                    
                        // Save objects to CoreData once they have been inserted into the context container
                        PersistenceService.saveContext()
                        
                        // Reload table to show new data
                        self.companiesTableView.reloadData()
                    
                    case .failure(let error):
                        print(error.localizedDescription)
                    
                }
        }
    }

}

extension CompaniesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.customerHasCompanies {
            return PersistenceService.customerCompaniesCount()
        }
        // Return the number of companies obtained via the HTTP request IF there are no company objects
        // stored in CoreData
        return self.companies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = Defaults.CellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // If we have items in CoreData, show them first
        if self.customerHasCompanies {
            print("Companies from CoreData will be shown")
            
            guard
                let coreDataCompanies = self.coreDataCompanies as? [Company]
            else { return cell }
            
            let company: Company = coreDataCompanies[indexPath.row]
            guard let address = company.shortenedAddress else { return cell }
            
            // Get date of appointment as a string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            guard let createdTimeDate: Date = company.created else { return cell }
            let createdTime: String = dateFormatter.string(from: createdTimeDate)
            
            cell.setup(title: address, subTitleOne: "Fort Pierce, FL", subTitleTwo: "34950", subTitleThree: createdTime)
            
        } else { // Show items from the NovaOne database that were obtained via an HTTP request
            print("Companies from the HTTP request will be shown")
            let company: CompanyModel = self.companies[indexPath.row] // Get the company object based on the row number each cell is in
            // Pass in appointment object to set up cell properties (address, city, etc.)
            let address = company.shortenedAddress
            
            // Get date of appointment as a string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            let createdTimeDate: Date = company.createdDate
            let createdTime: String = dateFormatter.string(from: createdTimeDate)
            
            cell.setup(title: address, subTitleOne: "Fort Pierce, FL", subTitleTwo: "34950", subTitleThree: createdTime)
        }
        
        return cell
    }
    
    // Function gets called every time a row in the table gets tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If we have companies from CoreData for the customer, use the coreDataCompanies array
        if self.customerHasCompanies {
            guard let coreDatacompany = self.coreDataCompanies?[indexPath.row] as? Company else { return } // Get company object based on which row the user taps on
            //Get detail view controller, pass object to it, and present it
            if let companyDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.companyDetail.rawValue) as? CompanyDetailViewController {
                companyDetailViewController.company = coreDatacompany
                self.navigationController?.pushViewController(companyDetailViewController, animated: true)
            }
        } else {
            let company = self.companies[indexPath.row] // Get company object based on which row the user taps on
            //Get detail view controller, pass object to it, and present it
            if let companyDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.companyDetail.rawValue) as? CompanyDetailViewController {
                companyDetailViewController.company = company
                self.navigationController?.pushViewController(companyDetailViewController, animated: true)
            }
        }
    }
    
}
