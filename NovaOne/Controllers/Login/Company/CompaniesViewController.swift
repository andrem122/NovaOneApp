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
        self.setupTableView()
    }
    
    func setupTableView() {
        self.companiesTableView.delegate = self
        self.companiesTableView.dataSource = self
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
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // If we have items in CoreData, show them first
        if self.customerHasCompanies {
            print("Companies from CoreData will be shown")
            
            guard
                let coreDataCompanies = self.coreDataCompanies as? [Company]
            else { return cell }
            
            let company: Company = coreDataCompanies[indexPath.row]
            guard
                let title = company.name,
                let city = company.city,
                let state = company.state,
                let zip = company.zip
            else { return cell }
            
            let subTitleOne = "\(city), \(state)"
            
            // Get date of appointment as a string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            guard let createdTimeDate: Date = company.created else { return cell }
            let createdTime: String = dateFormatter.string(from: createdTimeDate)
            
            
            cell.setup(title: title, subTitleOne: subTitleOne, subTitleTwo: zip, subTitleThree: createdTime)
            
        } else { // Show items from the NovaOne database that were obtained via an HTTP request
            print("Companies from the HTTP request will be shown")
            let company: CompanyModel = self.companies[indexPath.row] // Get the company object based on the row number each cell is in
            // Pass in appointment object to set up cell properties (address, city, etc.)
            let title = company.name
            let subTitleOne = "\(company.city), \(company.state)"
            
            // Get date of appointment as a string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            let createdTimeDate: Date = company.createdDate
            let createdTime: String = dateFormatter.string(from: createdTimeDate)
            
            cell.setup(title: title, subTitleOne: subTitleOne, subTitleTwo: company.zip, subTitleThree: createdTime)
        }
        
        return cell
    }
    
    // Function gets called every time a row in the table gets tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
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
