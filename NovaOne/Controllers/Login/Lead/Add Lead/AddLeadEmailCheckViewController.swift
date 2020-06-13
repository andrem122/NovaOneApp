//
//  AddLeadEmailCheckViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadEmailCheckViewController: AddLeadBaseViewController {
    
    // MARK: Properties
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     // MARK: Actions
    @IBAction func yesButtonTapped(_ sender: Any) {
        // Go to addLeadEmailViewController
        guard let addLeadEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadEmail.rawValue) as? AddLeadEmailViewController else { return }
        
        addLeadEmailViewController.lead = self.lead
        addLeadEmailViewController.embeddedViewController = self.embeddedViewController
        
        self.navigationController?.pushViewController(addLeadEmailViewController, animated: true)
    }
    
    
    @IBAction func noButtonTapped(_ sender: Any) {
        // Go to addLeadPhoneNumberCheckViewController
        guard let addLeadPhoneNumberCheckViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadPhoneCheck.rawValue) as? AddLeadPhoneCheckViewController else { return }
        
        addLeadPhoneNumberCheckViewController.lead = self.lead
        addLeadPhoneNumberCheckViewController.embeddedViewController = self.embeddedViewController
        
        self.navigationController?.pushViewController(addLeadPhoneNumberCheckViewController, animated: true)
    }
    
}
