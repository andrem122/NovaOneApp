//
//  LeadsContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LeadsContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLeads()
    }
    
    func getLeads() {
        // Gets appointments from the database via an HTTP request
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
                                            
                                            if let leadsViewController = leadsViewController as? LeadsViewController {
                                                leadsViewController.leads = leads
                                            }
                                            
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
