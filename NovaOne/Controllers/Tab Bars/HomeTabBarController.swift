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
        self.setBadgeValues()
        self.navigationController?.navigationBar.isHidden = true
        AppDelegate.delegate = self
        self.selectIndexForTabBar()
    }
    
    func setBadgeValues() {
        // Set the badge values for each tab bar item when the view loads
        let newLeadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.newLeadCount.rawValue)
        let newAppointmentCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.newAppointmentCount.rawValue)
        
        self.tabBar.items?[1].badgeValue = String(newAppointmentCount)
        self.tabBar.items?[2].badgeValue = String(newLeadCount)
    }
    
    override func viewDidLayoutSubviews() {
        //self.popOutMenu()
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuLauncher.toggleMenu(completion: nil)
    }
    
    func selectIndexForTabBar() {
        // Selects the index for the tab bar controller
        guard let selectIndex = self.selectIndex else {
            print("could not get selectIndex - HomeTabBarController")
            return
        }
        
        self.selectedIndex = selectIndex
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
        // If the tab bar item has a badge value and is selected, remove the badge value
        item.badgeValue = nil
        // Reset the badge value count to zero for the screen you are on
        if self.selectedIndex == 1 {
            // Appointments table view
            UserDefaults.standard.set(0, forKey: Defaults.UserDefaults.newAppointmentCount.rawValue)
            UserDefaults.standard.synchronize()
        } else if self.selectedIndex == 2 {
            // Leads table view
            UserDefaults.standard.set(0, forKey: Defaults.UserDefaults.newLeadCount.rawValue)
            UserDefaults.standard.synchronize()
        }
        
    }
}

extension HomeTabBarController: NovaOneAppDelegate {
    func didReceiveRemoteNotification(badgeValue: Int, selectIndex: Int) {
        // Set the badgeValue for the appropriate tab bar icon after receiveing the remote notification in AppDelegate if
        // the user is NOT on the current screen for the index in the tab bar controller
        if self.selectedIndex != selectIndex {
            self.tabBar.items?[selectIndex].badgeValue = String(badgeValue)
        }
    }
}
