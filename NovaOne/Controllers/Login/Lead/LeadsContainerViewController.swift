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
    var loadingIndicator: UIActivityIndicatorView?
    let objectCount = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue)
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showCoreDataOrRequestData()
    }
    
    func showCoreDataOrRequestData() {
        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
        
        if self.objectCount > 0 {
            // Get CoreData objects and pass to the next view
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.leads.rawValue, containerView: self.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            self.getData()
        }
        
    }
    
    func saveObjectsToCoreDataAndSend(for leadstableViewController: LeadsTableViewController, objects: [Decodable]) {
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
                    coreDataLead.company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
    
                    
                }
            }
        
        // Save objects to CoreData once they have been inserted into the context container
        PersistenceService.saveContext()
        
        // Send the data to the leads view controller
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let coreDataLeads = PersistenceService.fetchEntity(Lead.self, filter: nil, sort: sortDescriptors)
        leadstableViewController.leads = coreDataLeads
        leadstableViewController.filteredLeads = coreDataLeads
        
    }
    
    func showLoadingIndicator() {
        // Shows the loading indicator
        self.loadingIndicator = UIActivityIndicatorView(style: .medium)
        self.loadingIndicator?.startAnimating()
        
        // Position the loading animation
        let x = self.view.bounds.size.width / 2
        let y = self.view.bounds.size.height / 2
        self.loadingIndicator?.center = CGPoint(x: x, y: y)
        
        guard let loadingIndicator = self.loadingIndicator else { return }
        self.view.addSubview(loadingIndicator)
    }
    
    func getData() {
        // Gets data from the database via an HTTP request
        // and saves to CoreData
        
        // Show the loading indicator while making a request
        self.showLoadingIndicator()
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
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
                            parameters: parameters) {
                                [weak self] (result) in
                                
                                switch result {
                                    
                                    case .success(let leads):
                                        self?.loadingIndicator?.stopAnimating()
                                        
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.leads.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self) {
                                            [weak self] (leadsSplitViewController) in
                                            
                                            guard
                                                let leadsSplitViewController = leadsSplitViewController as? UISplitViewController,
                                                let leadsNavigationController = leadsSplitViewController.viewControllers.first as? UINavigationController,
                                                let leadsTableViewController = leadsNavigationController.viewControllers.first as? LeadsTableViewController
                                            else { return }
                                            
                                            // Save data in CoreData
                                            self?.saveObjectsToCoreDataAndSend(for: leadsTableViewController, objects: leads)
                                            
                                    }
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        // No leads were found or an error occurred so show/embed the empty
                                        // view controller
                                        
                                        self?.loadingIndicator?.stopAnimating()

                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Leads") {
                                            (emptyViewController) in
                                            
                                            // Tell the empty state view controller what its parent view controller is
                                            emptyViewController.parentViewContainerController = self
                                        
                                    }
                                    
                                }
                                
        }
        
    }
    
}
