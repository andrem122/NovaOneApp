//
//  UpdateAppointmentDateOfBirthViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentDateOfBirthViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
    
}
