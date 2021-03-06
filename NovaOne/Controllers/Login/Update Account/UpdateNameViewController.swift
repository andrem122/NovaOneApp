//
//  UpdateNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateNameViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var firstNameTextField: NovaOneTextField!
    @IBOutlet weak var lastNameTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    func setupTextFields() {
        // Setup text fields
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
    }
    

    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        guard
            let firstName = self.firstNameTextField.text?.trim(),
            let lastName = self.lastNameTextField.text?.trim()
        else { return }
        
        if firstName.isEmpty || lastName.isEmpty {
            
            let popUpOkViewController = self.alertService.popUpOk(title: "Enter Name", body: "Please enter your first and last name.")
            self.present(popUpOkViewController, animated: true, completion: nil)
            
        } else {
            guard
                let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                let previousViewController = self.previousViewController as? AccountTableViewController
            else { return }
            let objectId = customer.userId
            
            let updateClosure = {
                (customer: Customer) in
                customer.firstName = firstName
                customer.lastName = lastName
            }
            
            let successDoneHandler = {
                previousViewController.setLabelValues()
                previousViewController.tableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.authUser.rawValue, at: ["first_name": firstName, "last_name": lastName], endpoint: "/updateName.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: updateClosure, filterFormat: "userId == %@", successSubtitle: "Name has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
        }
    }
    
    @IBAction func firstNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) { () -> Bool in
            
            guard
                let firstName = self.firstNameTextField.text,
                let lastName = self.lastNameTextField.text
            else { return false }
            
            if firstName.isEmpty {
                return false
            }
            
            if lastName.isEmpty {
                return false
            }
            
            return true
            
        }
    }
    
    @IBAction func lastNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) { () -> Bool in
            
            guard
                let firstName = self.firstNameTextField.text,
                let lastName = self.lastNameTextField.text
            else { return false }
            
            if firstName.isEmpty {
                return false
            }
            
            if lastName.isEmpty {
                return false
            }
            
            return true
            
        }
    }
}

extension UpdateNameViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        } else {
            self.updateButton.sendActions(for: .touchUpInside)
        }
        return true
    }
    
}
