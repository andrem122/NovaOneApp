//
//  AddLeadCompanyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class AddLeadCompanyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
        var options: [EnableOption] = []
    var companies: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCompanies()
        self.setupTableView()
        self.setupNavigationBar()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupNavigationBar() {
        // Set navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    func getCompanies() {
        // Get customer companies from CoreData or an HTTP request
        
        // For CoreData
        if PersistenceService.customerHasCompanies() {
            
            guard let companies = PersistenceService.fetchCustomerCompanies() as? [Company] else { return }
            
            // Set up attributes for options array
            for company in companies {
                
                guard let companyName = company.name else { return }
                
                let option = EnableOption(option: companyName, selected: false, id: Int(company.id))
                
                self.options.append(option)
                
            }
            
        } else { // For HTTP request
            
            guard
                let customer = PersistenceService.fetchCustomerEntity(),
                let email = customer.email,
                let password = KeychainWrapper.standard.string(forKey: "password")
            else {
                print("Failed to obtain variables for POST request")
                return
            }
            let customerUserId = customer.id
            
            let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                             "email": email as Any,
                                             "password": password as Any]
            let httpRequest = HTTPRequests()
            httpRequest.request(endpoint: "/companies.php", dataModel: [CompanyModel].self, parameters: parameters) { (result) in
                
                switch result {
                    case .success(let companies):
                        
                        for company in companies {
                            let option = EnableOption(option: company.name, selected: false, id: Int(company.id))
                            self.options.append(option)
                            
                            // Save to CoreData
                            guard let entity = NSEntityDescription.entity(forEntityName: "Company", in: PersistenceService.context) else { return }
                            
                            if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
                                coreDataCompany.address = company.address
                                coreDataCompany.city = company.city
                                coreDataCompany.state = company.state
                                coreDataCompany.zip = company.zip
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
                            
                            PersistenceService.saveContext()
                        }
                    
                        self.tableView.reloadData()
                        
                    
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                
            }
            
        }
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AddLeadCompanyViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Deselect all other selections. Only one company may be selected
        for (count, _) in self.options.enumerated() {
            self.options[count].selected = false
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        let selected = cell.toggleCheckMark(cell: cell)
        self.options[indexPath.row].selected = selected
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let enableOption = self.options[indexPath.row] // Get the EnableOption object
        cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
        return cell
        
    }
    
}
