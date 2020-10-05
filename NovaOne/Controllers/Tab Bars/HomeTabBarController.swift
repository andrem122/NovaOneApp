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
        self.addNotificationObservers()
        self.selectIndexForTabBar()
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
    
    func addNotificationObservers() {
        // Adds notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBadgeCount(notification:)), name: Notification.Name(Defaults.NotificationObservers.newData.rawValue), object: nil)
    }
    
    @objc func updateBadgeCount(notification: Notification) {
        // Updates the badge count on the ui tab bar icons
        guard
            let userInfo = notification.userInfo,
            let badgeValue = userInfo["badgeValue"] as? Int,
            let selectIndex = userInfo["selectIndex"] as? Int else {
            print("could not get badge value - HomeTabBarController")
            return
        }
        
        self.tabBar.items?[selectIndex].badgeValue = String(badgeValue)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension HomeTabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // If the tab bar item has a badge value and is selected, remove the badge value
        item.badgeValue = nil
    }
}
