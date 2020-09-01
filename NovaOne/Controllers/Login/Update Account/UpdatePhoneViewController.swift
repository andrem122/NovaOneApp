//
//  UpdatePhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdatePhoneViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var phoneNumberTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.phoneNumberTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: Actions
    @IBAction func phoneNumberTextFieldChanged(_ sender: Any) {
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Parameter values
        guard let phoneNumber = self.phoneNumberTextField.text else { return }
        let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        if !unformattedPhoneNumber.isNumeric {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter only numbers.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            let spinnerView = self.showSpinner(for: self.view, textForLabel: "Updating")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": "+1" + unformattedPhoneNumber, "tableName": Defaults.DataBaseTableNames.customer.rawValue, "columnName": "phone_number"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(_):
                        guard
                            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                            let previousViewController = self?.previousViewController as? AccountTableViewController
                        else {
                            self?.removeSpinner(spinnerView: spinnerView)
                            return
                        }
                        
                        let objectId = customer.id
                    
                        let updateClosure = {
                            (customer: Customer) in
                            customer.phoneNumber = "+1" + unformattedPhoneNumber
                        }
                        
                        let successDoneHandler = {
                            previousViewController.setLabelValues()
                            previousViewController.tableView.reloadData()
                        }
                    
                        self?.updateObject(for: Defaults.DataBaseTableNames.customer.rawValue, at: ["phone_number": "+1" + unformattedPhoneNumber], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Customer.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Phone number successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                self?.removeSpinner(spinnerView: spinnerView)
                
                guard let button = self?.updateButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
            }
        }
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
