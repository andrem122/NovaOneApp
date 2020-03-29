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
                            dataModel: [LeadModel(id: 1)],
                            parameters: parameters) { [weak self] (result) in
                                
                                // Get anchor constraints from container view so that we can layout the views
                                // that will be embedded in it
                                guard
                                    let containerViewLeadingAnchor = self?.containerView.leadingAnchor,
                                    let containerViewTrailingAnchor = self?.containerView.trailingAnchor,
                                    let containerViewTopAnchor = self?.containerView.topAnchor,
                                    let containerViewBottomAnchor = self?.containerView.bottomAnchor
                                else { return }
                                
                                switch result {
                                    
                                    case .success(let leads):
                                        
                                        if let leadsViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.leads.rawValue) as? LeadsViewController {
                                            leadsViewController.leads = leads
                                            
                                            // Embed appointments view controller into container view so it will show
                                            self?.addChild(leadsViewController)
                                            leadsViewController.view.translatesAutoresizingMaskIntoConstraints = false
                                            self?.containerView.addSubview(leadsViewController.view)
                                            
                                            // Set constraints for embedded view so it shows correctly
                                            NSLayoutConstraint.activate([
                                                leadsViewController.view.leadingAnchor.constraint(equalTo: containerViewLeadingAnchor),
                                                leadsViewController.view.trailingAnchor.constraint(equalTo: containerViewTrailingAnchor),
                                                leadsViewController.view.topAnchor.constraint(equalTo: containerViewTopAnchor),
                                                leadsViewController.view.bottomAnchor.constraint(equalTo: containerViewBottomAnchor)
                                            ])
                                            
                                            leadsViewController.didMove(toParent: self)
                                            
                                            // Save to CoreData for future display
                                        }
                                        
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        
                                        // No appointments were found or an error occurred so embed the empty
                                        // view controller
                                        if let emptyViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.empty.rawValue) as? EmptyViewController {
                                            
                                            // Run on main thread to avoid a crash
                                            // UILabel will not be found if you try to change the label text with a background thread
                                            DispatchQueue.main.async {
                                                emptyViewController.setupTitle(title: "No Leads")
                                            }
                                            
                                            self?.addChild(emptyViewController)
                                            emptyViewController.view.translatesAutoresizingMaskIntoConstraints = false
                                            self?.containerView.addSubview(emptyViewController.view)
                                            
                                            // Set constraints for embedded view so it shows correctly
                                            NSLayoutConstraint.activate([
                                                emptyViewController.view.leadingAnchor.constraint(equalTo: containerViewLeadingAnchor),
                                                emptyViewController.view.trailingAnchor.constraint(equalTo: containerViewTrailingAnchor),
                                                emptyViewController.view.topAnchor.constraint(equalTo: containerViewTopAnchor),
                                                emptyViewController.view.bottomAnchor.constraint(equalTo: containerViewBottomAnchor)
                                            ])
                                            
                                            emptyViewController.didMove(toParent: self)
                                            
                                        }
                                }
                                
        }
        
    }

}
