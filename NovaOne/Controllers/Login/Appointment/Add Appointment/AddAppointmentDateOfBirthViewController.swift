//
//  AddAppointmentDateOfBirthViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentDateOfBirthViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Pass the date of birth to the appointment object
        let dateOfBirth = self.datePicker.date
        self.appointment?.dateOfBirth = DateHelper.createString(from: dateOfBirth, format: "MM/dd/yyyy")
        
        // Go to addAppointmentGender view controller
        guard let addAppointmentTestTypeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentTestType.rawValue) as? AddAppointmentTestTypeViewController else { return }
        
        addAppointmentTestTypeViewController.appointment = self.appointment
        
        self.navigationController?.pushViewController(addAppointmentTestTypeViewController, animated: true)
    }
}
