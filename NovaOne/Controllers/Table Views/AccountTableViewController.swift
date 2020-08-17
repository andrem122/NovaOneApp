//
//  AccountTableViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var customerIdValueLabel: UILabel!
    @IBOutlet weak var emailAddressValueLabel: UILabel!
    @IBOutlet weak var phoneNumberValueLabel: UILabel!
    var customer: Customer?
    var alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
        self.setLabelValues()
    }
    
    func setLabelValues() {
       // Set values for each label
        guard
            let emailAddress = self.customer?.email,
            let phoneNumber = self.customer?.phoneNumber,
            let fullName = self.customer?.fullName,
            let customerId = self.customer?.id
        else { return }
        
        self.nameValueLabel.text = fullName
        self.customerIdValueLabel.text = String(customerId)
        self.emailAddressValueLabel.text = emailAddress
        self.phoneNumberValueLabel.text = phoneNumber
        
        // Setup navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set text for back button on next view controller
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        guard let updateViewController = segue.destination as? UpdateBaseViewController else { return }
        updateViewController.updateCoreDataObjectId = self.customer?.id
        updateViewController.previousViewController = self
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 4 {
            // Sign out table row
            
            // Show a popup confirming sign out action
            let title = "Sign Out?"
            let body = "Are you sure you want to sign out?"
            let buttonTitle = "Yes"
            let popUpActionViewController = self.alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
                [weak self] in
                // Delete all CoreData data from previous logins
                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.customer.rawValue)
                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.company.rawValue)
                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.lead.rawValue)
                PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.appointment.rawValue)
                
                // Update UserDefaults
                UserDefaults.standard.set(false, forKey: Defaults.UserDefaults.isLoggedIn.rawValue)
                UserDefaults.standard.synchronize()
                
                // Take the user back to start view controller
                let mainStoryboard = UIStoryboard(name: Defaults.StoryBoards.main.rawValue, bundle: .main)
                guard let startViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController else { return }
                
                self?.present(startViewController, animated: true, completion: nil)
                
                }, cancelHandler: {
                    print("Sign out action canceled")
            })
            
            // Present the action popup
            self.present(popUpActionViewController, animated: true, completion: nil)
        }
    }
    
}
