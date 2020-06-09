//
//  AddAppointmentNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentNameViewController: AddAppointmentBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var appointmentNameTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appointmentNameTextField.delegate = self
        UIHelper.disable(button: continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let addPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentPhone.rawValue) as? AddAppointmentPhoneViewController else { return }
        
        guard let name = self.appointmentNameTextField.text else { return }
        self.appointment?.name = name
        addPhoneViewController.appointment = self.appointment
        addPhoneViewController.appointmentsTableViewController = self.appointmentsTableViewController
        
        self.navigationController?.pushViewController(addPhoneViewController, animated: true)
    }
    
    
    @IBAction func appointmentNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.appointmentNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    
}

extension AddAppointmentNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
