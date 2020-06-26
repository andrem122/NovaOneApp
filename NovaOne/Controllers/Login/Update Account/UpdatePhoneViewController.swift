//
//  UpdatePhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdatePhoneViewController: UpdateBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var phoneNumberTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    func setupUpdateButton() {
        // Setup the update button
        UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    func setupTextField() {
        // Setup the text field
        self.phoneNumberTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func phoneNumberTextFieldChanged(_ sender: Any) {
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let updateValue = self.phoneNumberTextField.text,
            let objectId = (self.updateObject as? Customer)?.id,
            let userId = (self.updateObject as? Customer)?.userId,
            let previousViewController = self.previousViewController as? AccountTableViewController
            else { return }
        
        let updateClosure = {
            (customer: Customer) in
            customer.phoneNumber = updateValue
        }
        
        let successDoneHandler = {
            [weak self] in
            
            let predicate = NSPredicate(format: "userId == %@", String(userId))
            guard let updatedCustomer = PersistenceService.fetchEntity(Customer.self, filter: predicate, sort: nil).first else { return }
            
            previousViewController.customer = updatedCustomer
            previousViewController.setLabelValues()
            previousViewController.tableView.reloadData()
            
            self?.removeSpinner()
            
        }
        
        self.updateObject(for: "customer_register_customer_user", at: ["phone_number": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: updateClosure, successSubtitle: "Phone number successfully updated.", successDoneHandler: successDoneHandler)
    }
}

extension UpdatePhoneViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var phoneNumber = textField.text else { return false }
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) {() -> Bool in
            
            let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
            
            // Add one to the unformatted phone number count because textfield.text
            // does NOT include the last typed character into the textfield
            if phoneNumber.isEmpty || string.isEmpty || unformattedPhoneNumber.count + 1 < 10 {
                return false
            }
            
            // Number entered is 10 digits and is not empty, so enable continue button
            return true
        }

        phoneNumber.append(string)
        if range.length == 1 {
            textField.text = InputFormatters.format(phoneNumber: phoneNumber, shouldRemoveLastDigit: true)
        } else {
            textField.text = InputFormatters.format(phoneNumber: phoneNumber)
        }
        
        return false
    }

}
