//
//  CompaniesContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class CompaniesContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    var customerHasCompanies: Bool = PersistenceService.customerHasCompanies()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCompanies()
    }
    
    func fetchCompanies() {
        // Get companies for customer from Coredata IF they exist else get them from the database
        
        if self.customerHasCompanies {
            guard let coreDataCompanies: [Any] = PersistenceService.fetchCustomerCompanies() else { return }
            
            // Pass to the companies view controller
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.companies.rawValue, containerView: self.containerView ?? UIView(), objectType: CompaniesViewController.self) { (companiesViewController) in
                
                if let companiesViewController = companiesViewController as? CompaniesViewController {
                    companiesViewController.coreDataCompanies = coreDataCompanies
                }
                
            }
            
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
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
            print("Failed to obtain variables for POST request")
            return
        }
        
        let parameters: [String: Any] = ["customerUserId": customer.id as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/companies.php", dataModel: [CompanyModel].self, parameters: parameters) {
            [weak self] (result) in
                switch result {
                    
                    case .success(let companies):
                        
                        
                        // Save the companies from the HTTP request in CoreData
                        guard let entity = NSEntityDescription.entity(forEntityName: "Company", in: PersistenceService.context) else { return }
                        
                        for company in companies {
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
                        }
                    
                        // Save objects to CoreData once they have been inserted into the context container
                        PersistenceService.saveContext()
                        
                        // Show the companies view controller
                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.companies.rawValue, containerView: self?.containerView ?? UIView(), objectType: CompaniesViewController.self) { (companiesViewController) in
                            
                            if let companiesViewController = companiesViewController as? CompaniesViewController {
                                companiesViewController.companies = companies
                            }
                            
                        }
                    
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                        // Show empty state view
                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Appointments", completion: nil)
                    
                }
        }
    }

}
