//
//  AddAppointmentEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentEmailViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func emailAddressTextFieldChanged(_ sender: Any) {
    }
    @IBAction func continueButtonTapped(_ sender: Any) {
    }
}
