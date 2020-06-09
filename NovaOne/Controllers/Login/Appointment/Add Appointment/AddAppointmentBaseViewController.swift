//
//  AddAppointmentBaseViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentBaseViewController: UIViewController {
    
    // MARK: Properties
    var appointment: AppointmentModel?
    var appointmentsTableViewController: AppointmentsTableViewController?
    let alertService = AlertService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
