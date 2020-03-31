//
//  AddAppointmentTimeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentTimeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Show the next view controller based on the customer type
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let customerType = customer.customerType
        else { return }
        
        // For property managers
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            // Navigate to add appointment unit type view controller
            if let addAppointmentUnitTypeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue) as? AddAppointmentUnitTypeViewController {
                self.present(addAppointmentUnitTypeViewController, animated: true, completion: nil)
            }
            
        }
        
    }
    
}
