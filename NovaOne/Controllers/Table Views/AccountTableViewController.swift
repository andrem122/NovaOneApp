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
    var hasEnabledPushNotificationsFromAccountView: Bool = false // A Boolean indicating whether or not the user has enabled push notifications with the official prompt from Apple from the account screen
    var alertService = AlertService()
    let updateBaseViewController = UpdateBaseViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLabelValues()
        self.addObservers()
        self.setNotificationSwitch()
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
        
        // Setup navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    func showPushNotificationPopup() {
        // Shows the push notification popup
        let title = "Notifications"
        let body = "Do you want to enable push notifications?"
        let buttonTitle = "Yes"
        DispatchQueue.main.async {
            [weak self] in
            guard let popupActionViewController = self?.alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
                self?.hasEnabledPushNotificationsFromAccountView = true // Set to true to prevent code from sending device token twice to server
                // Prompt user to register for push notifications with the official prompt
                AppDelegate.registerForPushNotifications()
            }, cancelHandler: {
                print("action canceled for push notifications permission - AccountTableViewController")
            }) else {
                return
            }
            
            self?.present(popupActionViewController, animated: true, completion: {
                [weak self] in
                self?.pushNotificationsActivityView.stopAnimating()
                self?.setNotificationSwitch()
            })
        }
    }
    
    @objc func setNotificationSwitch() {
        // Sets the value of the notification switch based on whether or not
        // notifications are enabled in the user's settings
        
        // If device token is nil, it means the user has never allowed push notifications OR has logged out
        let deviceToken = UserDefaults.standard.string(forKey: Defaults.UserDefaults.deviceToken.rawValue)
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] (settings) in
            let isAuthorized = settings.authorizationStatus == .authorized
            
            DispatchQueue.main.async {
                [weak self] in
                
                if isAuthorized && deviceToken != nil {
                    self?.pushNotificationsSwitch.setOn(true, animated: false)
                } else {
                    // Denied, not determined, or no token on server
                    if (isAuthorized && self?.hasEnabledPushNotificationsFromAccountView == false) || (isAuthorized && deviceToken == nil && self?.hasEnabledPushNotificationsFromAccountView == false) {
                        // IF push notifications authorized when coming back into the app
                        // AND user is not enabling push notifications for the first time with the official prompt
                        // OR push notifications authorized from settings and device token was not sent to server
                        // THEN send device token to server
                        AppDelegate.registerForPushNotifications()
                        self?.pushNotificationsSwitch.setOn(true, animated: false)
                        return
                    } else if isAuthorized && self?.hasEnabledPushNotificationsFromAccountView == true {
                        // IF application is becoming active from the official push notification prompt being dissmissed after
                        // user has enabled push notifications
                        self?.pushNotificationsSwitch.setOn(true, animated: false)
                        return
                    }
                    
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
                self?.unregisterForPushNotifications()
                
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
        let deviceToken = UserDefaults.standard.string(forKey: Defaults.UserDefaults.deviceToken.rawValue)
        center.getNotificationSettings { [weak self] (settings) in
            let isAuthorized = settings.authorizationStatus == .authorized
            let wasDenied = settings.authorizationStatus == .denied
            
            if isAuthorized && deviceToken != nil || !isAuthorized && deviceToken != nil || wasDenied {
                // User has denied push notifications from the offcial prompt
                self?.showSettingsPopup {
                    [weak self] in
                    self?.pushNotificationsActivityView.stopAnimating()
                    self?.setNotificationSwitch()
                }
            } else {
                // User has never allowed push notifications for NovaOne
                // Showing the official apple notification popup for the first time
                self?.showPushNotificationPopup()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
