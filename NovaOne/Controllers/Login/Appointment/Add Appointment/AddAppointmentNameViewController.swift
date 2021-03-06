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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appointmentNameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let name = self.appointmentNameTextField.text else { return }
        if name.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Name Required", body: "Please type in a name.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let addPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentPhone.rawValue) as? AddAppointmentPhoneViewController else { return }
            self.appointment?.name = name
            addPhoneViewController.appointment = self.appointment
            addPhoneViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addPhoneViewController, animated: true)
        }
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
