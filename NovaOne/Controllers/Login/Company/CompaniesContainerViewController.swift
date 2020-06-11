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
    var objectCount: Int = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showCoreDataOrRequestData()
    }
    
    func showCoreDataOrRequestData() {
        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
        
        if self.objectCount > 0 {
            // Get CoreData objects and pass to the next view
            print("Showing objects from Core Data")
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self.containerView, objectType: UISplitViewController.self, completion: nil)
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            print("No Core Data. Getting objects via an HTTP request")
            self.getData()
        }
        
    }
    
    func saveToCoreData(objects: [Decodable]) {
        // Saves objects data to CoreData
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: PersistenceService.context) else { return }
        
        guard let companies = objects as? [CompanyModel] else { return }
        for company in companies {
            if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
                
                coreDataCompany.address = company.address
                coreDataCompany.city = company.city
                coreDataCompany.created = company.createdDate
                coreDataCompany.customerUserId = Int32(company.customerUserId)
                coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
                coreDataCompany.email = company.email
                coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
                coreDataCompany.id = Int32(company.id)
                coreDataCompany.name = company.name
                coreDataCompany.phoneNumber = company.phoneNumber
                coreDataCompany.shortenedAddress = company.shortenedAddress
                coreDataCompany.state = company.state
                coreDataCompany.zip = company.zip
                
                // Add appointments
                if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.appointment.rawValue) > 0 {
                    let predicate = NSPredicate(format: "companyId == %@", String(company.id))
                    let appointments = NSSet(array: PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil))
                    coreDataCompany.addToAppointments(appointments)
                }
                
                // Add leads
                if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue) > 0 {
                    let predicate = NSPredicate(format: "companyId == %@", String(company.id))
                    let leads = NSSet(array: PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil))
                    coreDataCompany.addToLeads(leads)
                }
                
                
            }
        }
        
        // Save objects to CoreData once they have been inserted into the context container
        PersistenceService.saveContext()
    }
    
    func getData() {
        // Gets data from the database via an HTTP request and saves to CoreData
        
        self.showSpinner(for: self.view, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/companies.php",
                            dataModel: [CompanyModel].self,
                            parameters: parameters) {
                                [weak self] (result) in
                                
                                switch result {
                                    
                                    case .success(let companies):
                                        // Save data in CoreData
                                        self?.saveToCoreData(objects: companies)
                                        
                                        // Show success screen
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
                                        
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        // No objects were found or an error occurred so show/embed the empty
                                        // view controller
                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Companies", addObjectButtonTitle: "Add Company") {
                                            (emptyViewController) in
                                            
                                            // Tell the empty state view controller what its parent view controller is
                                            emptyViewController.parentViewContainerController = self
                                        
                                    }
                                    
                                }
                                
                                self?.removeSpinner()
        }
        
    }

}
