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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        
        // Set values for each label
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, with: nil, sort: nil).first,
            let emailAddress = customer.email,
            let phoneNumber = customer.phoneNumber
        else { return }
        
        self.nameValueLabel.text = customer.fullName
        self.customerIdValueLabel.text = String(customer.id)
        self.emailAddressValueLabel.text = emailAddress
        self.phoneNumberValueLabel.text = phoneNumber
        
        // Setup navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set text for back button on next view controller
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
