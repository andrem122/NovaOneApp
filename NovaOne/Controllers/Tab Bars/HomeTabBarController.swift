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
    let menuLauncher = MenuLauncher()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuLauncher.showMenu()
    }
    
}
