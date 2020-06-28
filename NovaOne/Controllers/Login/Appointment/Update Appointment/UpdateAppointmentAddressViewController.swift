//
//  UpdateAppointmentAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentAddressViewController: UpdateBaseViewController {

    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var addressTextField: NovaOneTextField!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func addressTextFieldChanged(_ sender: Any) {
    }
    
}
