//
//  AddCompanyAllowSameDayAppointmentsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyAllowSameDayAppointmentsViewController: AddCompanyBaseViewController {
    
    // MARK: Properties

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func goToAddCompanyDaysEnabled() -> Void {
        guard
            let addCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue) as? AddCompanyDaysEnabledViewController
        else { return }
        
        addCompanyDaysEnabledViewController.company = self.company
        addCompanyDaysEnabledViewController.embeddedViewController = self.embeddedViewController
        
        self.navigationController?.pushViewController(addCompanyDaysEnabledViewController, animated: true)
    }
    
    // MARK: Actions
    @IBAction func yesButtonTapped(_ sender: Any) {
        self.company?.allowSameDayAppointments = true
        goToAddCompanyDaysEnabled()
    }
    
    
    @IBAction func noButtonTapped(_ sender: Any) {
        self.company?.allowSameDayAppointments = false
        goToAddCompanyDaysEnabled()
    }
    
}
