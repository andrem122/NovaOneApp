//
//  LeadsContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class LeadsContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    let objectCount = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showCoreDataOrRequestData()
    }
    
    func showCoreDataOrRequestData() {
        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
        
        if self.objectCount > 0 {
            print("SHOWING LEADS FROM CORE DATA")
            // Get CoreData objects and pass to the next view
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.leads.rawValue, containerView: self.containerView ?? UIView(), objectType: LeadsViewController.self, completion: nil)
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            self.getData()
        }
        
    }
    
    func saveObjectsToCoreDataAndSend(for leadsViewController: LeadsViewController, objects: [Decodable]) {
        // Saves leads data to CoreData and sends them to leads view for display
        
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.lead.rawValue, in: PersistenceService.context) else { return }
            
            guard let leads = objects as? [LeadModel] else { return }
            for lead in leads {
                if let coreDataLead = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Lead {
                    
                    coreDataLead.id = Int32(lead.id)
                    coreDataLead.name = lead.name
                    coreDataLead.phoneNumber = lead.phoneNumber
                    coreDataLead.email = lead.email
                    coreDataLead.dateOfInquiry = lead.dateOfInquiryDate
                    coreDataLead.renterBrand = lead.renterBrand
                    coreDataLead.companyId = Int32(lead.companyId)
                    coreDataLead.sentTextDate = lead.sentTextDateDate
                    coreDataLead.sentEmailDate = lead.sentEmailDateDate
                    coreDataLead.filledOutForm = lead.filledOutForm
                    coreDataLead.madeAppointment = lead.madeAppointment
                    coreDataLead.companyName = lead.companyName
                    
                    let predicate = NSPredicate(format: "id == %@", String(lead.companyId))
                    coreDataLead.company = PersistenceService.fetchEntity(Company.self, with: predicate, sort: nil).first
    
                    
                }
            }
        
        // Save objects to CoreData once they have been inserted into the context container
        PersistenceService.saveContext()
        
        // Send the data to the leads view controller
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        leadsViewController.leads = PersistenceService.fetchEntity(Lead.self, with: nil, sort: sortDescriptors)
        
    }
    
    func getData() {
        // Gets data from the database via an HTTP request
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
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/leads.php",
                            dataModel: [LeadModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                switch result {
                                    
                                    case .success(let leads):
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.leads.rawValue, containerView: self?.containerView ?? UIView(), objectType: LeadsViewController.self) { (leadsViewController) in
                                            
                                            guard let leadsViewController = leadsViewController as? LeadsViewController else { return }
                                            // Save data in CoreData
                                            self?.saveObjectsToCoreDataAndSend(for: leadsViewController, objects: leads)
                                            
                                    }
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        
                                        // No leads were found or an error occurred so show/embed the empty
                                        // view controller
                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView())
                                }
                                
        }
        
    }

}
