//
//  AddLeadNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadNameViewController: AddLeadBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var nameTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContinueButton()
        self.setupTextField()
    }
    
    func setupTextField() {
        self.nameTextField.delegate = self
    }
    
    func setupContinueButton() {
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }

    // MARK: Actions
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.nameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Go to addLeadEmailCheckViewController
        guard let addLeadEmailCheckViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadEmailCheck.rawValue) as? AddLeadEmailCheckViewController else { return }
        
        guard let name = self.nameTextField.text else { return }
        self.lead?.name = name
        addLeadEmailCheckViewController.lead = self.lead
        addLeadEmailCheckViewController.embeddedViewController = self.embeddedViewController
        
        self.navigationController?.pushViewController(addLeadEmailCheckViewController, animated: true)
    }
    
}

extension AddLeadNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
