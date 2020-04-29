//
//  BaseViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class BaseLoginViewController: UIViewController {
    // This class sets up all the basics (menu navigation, navigation bar style, etc.)
    // for every view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupNavigationBar(for viewController: UIViewController, navigationBar: UINavigationBar?, navigationItem: UINavigationItem?) {
        // Sets up the navigation bar styles, buttons, attributes, etc.
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash")?.withRenderingMode(.alwaysOriginal).withTintColor(Defaults.novaOneColor), style: .plain, target: viewController, action: #selector(self.handleMenuToggle))
        
        // For views with navigation bars added in the storyboard
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        navigationItem?.leftBarButtonItem = leftBarButtonItem
        
        // For views embedded in navigation controllers
        guard let unwrappedNavigationController = self.navigationController else { return }
        
        // Set style
        unwrappedNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        unwrappedNavigationController.navigationBar.shadowImage = UIImage()
        
        // Set bar button items
        unwrappedNavigationController.navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }
    
    @objc func handleMenuToggle() {
        print("Toggle menu...")
    }

}
