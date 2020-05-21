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
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        //self.popOutMenu()
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuLauncher.toggleMenu(completion: nil)
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
