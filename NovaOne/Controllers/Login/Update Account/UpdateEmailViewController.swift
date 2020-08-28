//
//  UpdateEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateEmailViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var emailTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.emailTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: Actions
    @IBAction func emailTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.emailTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = emailTextField.text?.trim() else { return }
        
        // If email is valid, check for it in the database before continuing
        if InputValidators.isValidEmail(email: updateValue) {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            let spinnerView = self.showSpinner(for: self.view, textForLabel: "Updating")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": updateValue, "tableName": Defaults.DataBaseTableNames.authUser.rawValue, "columnName": "email"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                    case .success(_):
                        guard
                            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                            let previousViewController = self?.previousViewController as? AccountTableViewController
                        else { return }
                        let objectId = customer.userId
                    
                    let updateClosure = {
                        (customer: Customer) in
                        customer.email = updateValue
                    }
                    
                    let successDoneHandler = {
                        previousViewController.setLabelValues()
                        previousViewController.tableView.reloadData()
                        
                        // Set new email in keychain
                        KeychainWrapper.standard.set(updateValue, forKey: Defaults.KeychainKeys.email.rawValue)
                    }
                    
                        self?.updateObject(for: Defaults.DataBaseTableNames.authUser.rawValue, at: ["email": updateValue], endpoint: "/updateEmail.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: updateClosure, filterFormat: "userId == %@", successSubtitle: "Email successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
                        
                        
                    case .failure(let error):
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let updateButton = self?.updateButton else { return }
                UIHelper.enable(button: updateButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner(spinnerView: spinnerView)
            }
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension UpdateEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
