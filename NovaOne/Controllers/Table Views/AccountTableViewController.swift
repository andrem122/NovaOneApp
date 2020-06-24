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
    var customer: Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
        self.setLabelValues()
    }
    
    func setLabelValues() {
       // Set values for each label
        print("SETTING LABEL VALUES")
        guard
            let emailAddress = self.customer?.email,
            let phoneNumber = self.customer?.phoneNumber,
            let fullName = self.customer?.fullName,
            let customerId = self.customer?.id
        else { return }
        
        self.nameValueLabel.text = fullName
        self.customerIdValueLabel.text = String(customerId)
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
        
        guard let updateViewController = segue.destination as? UpdateBaseViewController else { return }
        updateViewController.updateObject = self.customer
        updateViewController.previousViewController = self
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
