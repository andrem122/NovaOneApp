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
    
    func navigate<T: UIViewController>(to viewController: String, viewControllerType: T.Type) {
        // Navigates to a view controller by pushing it onto the navigation controller stack
        if let viewController = self.storyboard?.instantiateViewController(identifier: viewController) as? T {
            
            // Need to access the navigation controller because we want to push the view controller
            // onto the navigation stack because it is not connected in the storyboard
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
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
            self.navigate(to: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue, viewControllerType: AddAppointmentUnitTypeViewController.self)
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            // Navigate to add appointment email view controller
            self.navigate(to: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue, viewControllerType: AddAppointmentEmailViewController.self)
        }
        
    }

}
