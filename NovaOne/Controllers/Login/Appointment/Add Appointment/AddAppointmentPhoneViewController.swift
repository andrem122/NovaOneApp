//
//  AddAppointmentPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentPhoneViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentPhoneTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: Actions
    @IBAction func appointmentPhoneTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.appointmentPhoneTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let addAppointmentTimeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentTime.rawValue) as? AddAppointmentTimeViewController else { return }
        
        guard let phoneNumber = self.appointmentPhoneTextField.text else { return }
        self.appointment?.phoneNumber = phoneNumber
        addAppointmentTimeViewController.appointment = self.appointment
        
        self.navigationController?.pushViewController(addAppointmentTimeViewController, animated: true)
    }
}
