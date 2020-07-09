//
//  LeadsContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class LeadsContainerViewController: UIViewController, NovaOneObjectContainer {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    var objectCount: Int = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue)
    
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
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.leads.rawValue, containerView: self.containerView, objectType: UISplitViewController.self, completion: nil)
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            print("No Core Data. Getting objects via an HTTP request")
            self.getData()
        }
        
    }
    
    func saveToCoreData(objects: [Decodable]) {
        // Saves leads data to CoreData and sends them to leads view for display
        
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.lead.rawValue, in: PersistenceService.context) else { return }
            
            guard let leads = objects as? [LeadModel] else { return }
            for lead in leads {
                if let coreDataLead = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Lead {
                    
                    guard let id = lead.id else { return }
                    coreDataLead.id = Int32(id)
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
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/leads.php",
                            dataModel: [LeadModel].self,
                            parameters: parameters) {
                                [weak self] (result) in
                                
                                switch result {
                                    
                                    case .success(let leads):
                                        // Save data in CoreData
                                        self?.saveToCoreData(objects: leads)
                                        
                                        // Show success screen
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.leads.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
                                        
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        // No leads were found or an error occurred so show/embed the empty
                                        // view controller
                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Leads", addObjectButtonTitle: "Add Lead") {
                                            (emptyViewController) in
                                            
                                            // Tell the empty state view controller what its parent view controller is
                                            emptyViewController.parentViewContainerController = self
                                            
                                            // Pass the addObjectHandler function and button title to the empty view controller
                                            emptyViewController.addObjectButtonHandler = {
                                                [weak self] in
                                                // Go to the add object screen
                                                let addLeadStoryboard = UIStoryboard(name: Defaults.StoryBoards.addLead.rawValue, bundle: .main)
                                                guard
                                                    let addLeadNavigationController = addLeadStoryboard.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addLead.rawValue) as? UINavigationController,
                                                    let addLeadCompanyViewController = addLeadNavigationController.viewControllers.first as? AddLeadCompanyViewController
                                                else { return }
                                                
                                                addLeadCompanyViewController.embeddedViewController = emptyViewController
                                                
                                                self?.present(addLeadNavigationController, animated: true, completion: nil)
                                            }
                                        
                                    }
                                    
                                }
                                self?.removeSpinner()
        }
        
    }
    
}
