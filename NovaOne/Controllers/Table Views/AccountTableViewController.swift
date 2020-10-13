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
    @IBOutlet weak var pushNotificationsActivityView: UIActivityIndicatorView!
    @IBOutlet weak var smsNotificationsSwitch: UISwitch!
    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    var alertService = AlertService()
    let updateBaseViewController = UpdateBaseViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLabelValues()
        self.addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNotificationSwitch), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        self.setNotificationSwitch()
        
        // Setup navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    @objc func setNotificationSwitch() {
        // Sets the value of the notification switch based on whether or not
        // notifications are enabled in the user's settings
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] (settings) in
            let isAuthorized = settings.authorizationStatus == .authorized
            
            DispatchQueue.main.async {
                [weak self] in
                
                if isAuthorized && !UIApplication.shared.isRegisteredForRemoteNotifications {
                    AppDelegate.registerForPushNotifications()
                    self?.pushNotificationsSwitch.setOn(true, animated: false)
                } else if isAuthorized && UIApplication.shared.isRegisteredForRemoteNotifications {
                    self?.pushNotificationsSwitch.setOn(true, animated: false)
                } else {
                    self?.pushNotificationsSwitch.setOn(false, animated: false)
                }
            }
        }
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
                
                // Unregister from push notifications
                UIApplication.shared.unregisterForRemoteNotifications()
                
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
        self.updateBaseViewController.updateObject(for: Defaults.DataBaseTableNames.customer.rawValue, at: ["wants_sms": switchFlag], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: nil, filterFormat: "id == %@", successSubtitle: nil, currentAuthenticationEmail: nil, successDoneHandler: nil) {
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
        self.updateBaseViewController.updateObject(for: Defaults.DataBaseTableNames.customer.rawValue, at: ["wants_email_notifications": switchFlag], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: nil, filterFormat: "id == %@", successSubtitle: nil, currentAuthenticationEmail: nil, successDoneHandler: nil) {
            [weak self] in
            self?.emailNotificationsActivityView.stopAnimating()
        }
        
    }
    
    @IBAction func pushNotificationsSwitchChanged(_ sender: Any) {
        // Animate and show activity view
        if self.pushNotificationsActivityView.isAnimating == false {
            self.pushNotificationsActivityView.startAnimating()
        } else {
            self.pushNotificationsActivityView.stopAnimating()
        }
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] (settings) in
            let isAuthorized = settings.authorizationStatus == .authorized
            let wasDenied = settings.authorizationStatus == .denied
            var popupActionViewController: UIViewController?
            
            if wasDenied || isAuthorized {
                // User wants to change push notification settings
                // OR the user denied push notifications before
                // Enable or disable push notifications by directing the user to the settings page
                let title = "Go To Settings?"
                let body = "You will now be redirected to settings to enable or disable push notifications for NovaOne."
                let buttonTitle = "Settings"
                
                DispatchQueue.main.async {
                    [weak self] in
                    popupActionViewController = self?.alertService.popUp(title: title, body: body, buttonTitle: buttonTitle) {
                        // Take the user to the settings page if they have enabled push notifications in the settings before
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    } cancelHandler: {
                        print("Action canceled for settings redirect - AccountTableViewController")
                    }
                }
            } else {
                // User has never allowed push notifications for NovaOne
                // Showing the official apple notification popup for the first time
                let title = "Notifications"
                let body = "Do you want to enable push notifications?"
                let buttonTitle = "Yes"
                DispatchQueue.main.async {
                    [weak self] in
                    popupActionViewController = self?.alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
                        // Prompt user to register for push notifications with the official prompt
                        AppDelegate.registerForPushNotifications()
                    }, cancelHandler: {
                        print("action canceled for push notifications permission - LoginViewController")
                    })
                }
            }
            
            DispatchQueue.main.async {
                [weak self] in
                self?.present(popupActionViewController!, animated: true, completion: {
                    [weak self] in
                    self?.pushNotificationsActivityView.stopAnimating()
                    self?.setNotificationSwitch()
                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
