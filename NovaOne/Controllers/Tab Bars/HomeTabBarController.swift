//
//  NovaOneTabBar.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/25/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController, UITableViewDelegate {
    
    // MARK: Properties
    let toggleMenuNotificationName = NSNotification.Name(Defaults.NotificationObservers.toggleMenu.rawValue)
    @IBOutlet weak var menuButton: UIBarButtonItem!
    lazy var menuLauncher: MenuLauncher = {
        let launcher = MenuLauncher(homeTabBarController: self)
        return launcher
    }()
    var selectIndex: Int?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        AppDelegate.delegate = self
        self.selectIndexForTabBar()
        self.addObservers()
    }
    
    func addObservers() {
        // Set the badge values for each tab bar item when the application becomes active from the background or launch
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(self.setBadgeValues),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func setBadgeValues() {
        // Sets badge values for tab bar items
        
        // Make POST request to obtain notification counts from the database
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerEmail = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
            print("could not get customer object - HomeTabBarController")
            return
        }
        
        let parameters: [String: Any] = ["customerUserId": customer.id, "email": customerEmail, "password": password]
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/notificationCounts.php", dataModel: [CustomerUserPushNotificationTokens].self, parameters: parameters) { [weak self] (result) in
            switch result {
            
                case .success(let customerUserPushNotificationToken):
                    guard
                        let newLeadCount = customerUserPushNotificationToken.first?.newLeadCount,
                        let newAppointmentCount = customerUserPushNotificationToken.first?.newAppointmentCount
                    else {
                        print("could not unwrap notification counts from customerUserPushNotificationToken object - HomeTabBarController")
                        return
                    }
                    
                    // Set badge values for each tab bar icon and for application
                    if newLeadCount > 0 {
                        // Leads
                        self?.tabBar.items?[2].badgeValue = String(newLeadCount)
                    }
                    
                    if newAppointmentCount > 0 {
                        // Appointments
                        self?.tabBar.items?[1].badgeValue = String(newAppointmentCount)
                    }
                    
                    
                case .failure(let error):
                    print("Failed to get notification counts: \(error.localizedDescription)")
                    
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        //self.popOutMenu()
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuLauncher.toggleMenu(completion: nil)
    }
    
    func selectIndexForTabBar() {
        // Selects the index for the tab bar controller when coming from a notification
        guard let selectIndex = self.selectIndex else {
            print("could not get selectIndex - HomeTabBarController")
            return
        }
        
        self.selectedIndex = selectIndex
        
        guard
            let tabBarItem = self.tabBar.items?[selectIndex],
            let notificationCountString = tabBarItem.badgeValue,
            let notificationCountInt = Int(notificationCountString)
        else { return }
        
        // Reset notification counts after ending up on a tab item from a notification
        tabBarItem.badgeValue = nil
        self.resetNotificationCount(for: selectIndex)
        
        // Subtract from the application badge number and update database application badge number
        UIApplication.shared.applicationIconBadgeNumber -= notificationCountInt
        self.updateApplicationBadgeCount(subtract: notificationCountInt)
    }
    
    func showViewForMenuOptionSelected(menuOption: MenuOption) {
        // Shows the view associated with the tapped on menu option
        let enumMenuOption = menuOption.enumMenuOption
        
        switch enumMenuOption {
        case .home:
            self.selectedIndex = 0
        case .appointments:
            self.selectedIndex = 1
        case .leads:
            self.selectedIndex = 2
        case .companies:
            self.selectedIndex = 3 // Account view
            
            guard let accountTableViewController = self.viewControllers?[3] as? UITableViewController else { return }
            guard let companiesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.companiesContainer.rawValue) as? CompaniesContainerViewController else { return }
    
            accountTableViewController.navigationController?.pushViewController(companiesContainerViewController, animated: true)
        case .account:
            self.selectedIndex = 3
        }
    }
    
}

extension HomeTabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // If the tab bar item has a badge value and is selected, remove the badge value from the
        // tab bar item and make a POST request to the server to set the badge value to zero
        // for the index associated with the object count (either lead or appointment objects for now)
        if item.badgeValue != nil {
            // Subtract the tab bar item number from the application badge number update the database value as well
            guard let notificationCount = Int(item.badgeValue!) else { return }
            
            UIApplication.shared.applicationIconBadgeNumber -= notificationCount
            self.updateApplicationBadgeCount(subtract: notificationCount)
            
            item.badgeValue = nil
            guard let itemIndex = self.tabBar.items?.firstIndex(of: item) else { return }
            self.resetNotificationCount(for: itemIndex)
        }
    }
}

extension HomeTabBarController: NovaOneAppDelegate {
    func didReceiveRemoteNotification(badgeValue: Int, selectIndex: Int) {
        // Set the badgeValue for the appropriate tab bar icon after receiveing the remote notification in AppDelegate if
        // the user is NOT on the current screen for the index in the tab bar controller
        if self.selectedIndex != selectIndex && badgeValue > 0 {
            self.tabBar.items?[selectIndex].badgeValue = String(badgeValue)
        }
    }
}
