//
//  UpdatePasswordViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UpdateBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var currentPasswordTextField: NovaOneTextField!
    @IBOutlet weak var newPasswordTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton()
        self.setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentPasswordTextField.becomeFirstResponder()
    }
    
    func setupUpdateButton() {
        // Setup the update button
        UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    func setupTextFields() {
        // Setup the text fields
        self.currentPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        // Check if password entered matches keychain password
        let currentPassword = self.currentPasswordTextField.text != nil ? self.currentPasswordTextField.text! : ""
        if currentPassword == KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue) {
            
            guard
                let newPassword = self.newPasswordTextField.text,
                let objectId = (self.updateObject as? Customer)?.userId,
                let previousViewController = self.previousViewController as? AccountTableViewController
            else { print("could not get previous view controller"); return }
            
            if newPassword.count < 10 {
                let popUpOkViewController = self.alertService.popUpOk(title: "Password Length", body: "Password must be at least ten characters long.")
                self.present(popUpOkViewController, animated: true, completion: nil)
                return
            }
            
            let updateClosure = {
                (customer: Customer) in
                customer.password = newPassword
            }
            
            let successDoneHandler = {
                [weak self] in
                
                let predicate = NSPredicate(format: "userId == %@", String(objectId))
                guard let updatedCustomer = PersistenceService.fetchEntity(Customer.self, filter: predicate, sort: nil).first else { return }
                
                previousViewController.customer = updatedCustomer
                previousViewController.setLabelValues()
                previousViewController.tableView.reloadData()
                
                // Set new password in keychain
                KeychainWrapper.standard.set(newPassword, forKey: Defaults.KeychainKeys.password.rawValue)
                
                self?.removeSpinner()
                
            }
            
            self.updateObject(for: "auth_user", at: ["password": newPassword], endpoint: "/updatePassword.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: updateClosure, successSubtitle: "Password has been successfully updated.", successDoneHandler: successDoneHandler)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Incorrect Password", body: "Password entered does not match current password.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func currentPasswordTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) {
            [weak self] () -> Bool in
            
            guard
                let currentPassword = self?.currentPasswordTextField.text,
                let newPassword = self?.newPasswordTextField.text
            else { return false }
            
            if currentPassword.isEmpty {
                return false
            }
            
            if newPassword.isEmpty {
                return false
            }
            
            return true
            
        }

    }
    
    @IBAction func newPasswordTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) {
            [weak self] () -> Bool in
            
            guard
                let currentPassword = self?.currentPasswordTextField.text,
                let newPassword = self?.newPasswordTextField.text
            else { return false }
            
            if currentPassword.isEmpty {
                return false
            }
            
            if newPassword.isEmpty {
                return false
            }
            
            return true
            
        }
    }
}

extension UpdatePasswordViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.currentPasswordTextField {
            self.newPasswordTextField.becomeFirstResponder()
        } else {
            self.updateButton.sendActions(for: .touchUpInside)
        }
        return true
    }
    
}
