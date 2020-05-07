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
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.popOutMenu()
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(_ sender: Any) {
        menuLauncher.toggleMenu()
    }
    
    func popOutMenu() {
        // Detects the size class and makes the menu stay open
        // if the size class is width and height of regular
        switch self.getSizeClass() {
            
        case (.unspecified, .unspecified):
            print("Unknown")
        case (.unspecified, .compact):
            print("Unknown width, compact height")
        case (.unspecified, .regular):
            print("Unknown width, regular height")
        case (.compact, .unspecified):
            print("Compact width, unknown height")
        case (.regular, .unspecified):
            print("Regular width, unknown height")
        case (.regular, .compact):
            print("Regular width, compact height")
        case (.compact, .compact):
            print("Compact width, compact height")
        case (.regular, .regular):
            print("Regular width, regular height")
            // Toggle the menu and hide the menu button
            menuLauncher.toggleMenu()
            self.menuButton.isEnabled = false
            self.menuButton.tintColor = .clear
        case (.compact, .regular):
            print("Compact width, regular height")
        case (_, _):
            print("None")
            
        }
        
    }
    
}
