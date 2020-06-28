//
//  UpdateAppointmentTimeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentTimeViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
    
}
