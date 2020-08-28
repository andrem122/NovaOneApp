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
    @IBOutlet weak var smsNotificationsActivityView: UIActivityIndicatorView!
    @IBOutlet weak var emailNotificationsActivityView: UIActivityIndicatorView!
    @IBOutlet weak var smsNotificationsSwitch: UISwitch!
    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    var alertService = AlertService()
    let updateBaseViewController = UpdateBaseViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLabelValues()
    }
    
    func setLabelValues() {
       // Set values for each label
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let emailAddress = customer.email,
            let phoneNumber = customer.phoneNumber
        else { return }
        let fullName = customer.fullName
        let customerId = customer.id
        
        self.nameValueLabel.text = fullName
        self.customerIdValueLabel.text = String(customerId)
        self.emailAddressValueLabel.text = emailAddress
        self.phoneNumberValueLabel.text = phoneNumber
        
        // Set switch values
        let wantsSms = customer.wantsSms
        let wantsEmailNotificatons = customer.wantsEmailNotifications
        
        self.smsNotificationsSwitch.setOn(wantsSms, animated: false)
        self.emailNotificationsSwitch.setOn(wantsEmailNotificatons, animated: false)
        
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
        guard let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first else { return }
        updateViewController.updateCoreDataObjectId = customer.id
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
    
    // MARK: Actions
    @IBAction func smsNotificationsSwitchChanged(_ sender: Any) {
        
        // Animate and show activity view
        if self.smsNotificationsActivityView.isAnimating == false {
            self.smsNotificationsActivityView.startAnimating()
        } else {
            self.smsNotificationsActivityView.stopAnimating()
        }
        
        // Set the database boolean value
        var switchFlag = "f"
        if self.smsNotificationsSwitch.isOn {
            switchFlag = "t"
        } else {
           switchFlag = "f"
        }
        
        guard let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first else { return }
        let objectId = customer.id
        self.updateBaseViewController.updateObject(for: Defaults.DataBaseTableNames.customer.rawValue, at: ["wants_sms": switchFlag], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: nil, filterFormat: "id == %@", successSubtitle: nil, successDoneHandler: nil) {
            [weak self] in
            self?.smsNotificationsActivityView.stopAnimating()
        }
    }
    
    @IBAction func emailNotificationsSwitchChanged(_ sender: Any) {
        
        // Animate and show activity view
        if self.emailNotificationsActivityView.isAnimating == false {
            self.emailNotificationsActivityView.startAnimating()
        } else {
            self.emailNotificationsActivityView.stopAnimating()
        }
        
        // Set the database boolean value
        var switchFlag = "f"
        if self.emailNotificationsSwitch.isOn {
            switchFlag = "t"
        } else {
           switchFlag = "f"
        }
        
        guard let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first else { return }
        let objectId = customer.id
        self.updateBaseViewController.updateObject(for: Defaults.DataBaseTableNames.customer.rawValue, at: ["wants_email_notifications": switchFlag], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: nil, filterFormat: "id == %@", successSubtitle: nil, successDoneHandler: nil) {
            [weak self] in
            self?.emailNotificationsActivityView.stopAnimating()
        }
        
    }
    
    
}
