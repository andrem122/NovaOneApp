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
    var customer: CustomerModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        
        print(viewController.description)
        if let propertiesViewController = viewController as? PropertiesViewController {
            propertiesViewController.customer = customer
            print("Properties View Controller")
        } else {
            print("Not properties view controller")
        }
        
        // Set text for back button on next view controller
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If properties cell is tapped on, navigate to navigation controller that
        // properties view controller is embedded in

    }
}
