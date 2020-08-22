//
//  UpdatePropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyPhoneViewController: UpdateBaseViewController {
    
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
            let parameters: [String: String] = ["valueToCheckInDatabase": "%2B1" + unformattedPhoneNumber, "tableName": Defaults.DataBaseTableNames.company.rawValue, "columnName": "phone_number"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                    case .success(_):
                        guard
                            let objectId = self?.updateCoreDataObjectId,
                            let detailViewController = self?.previousViewController as? CompanyDetailViewController
                            else { return }

                        let updateClosure = {
                            (company: Company) in
                            company.phoneNumber = "+1" + unformattedPhoneNumber
                        }

                        let successDoneHandler = {
                            let predicate = NSPredicate(format: "id == %@", String(objectId))
                            guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { return }

                            detailViewController.coreDataObjectId = updatedCompany.id
                            detailViewController.setupObjectDetailCellsAndTitle()
                            detailViewController.objectDetailTableView.reloadData()

                        }

                        self?.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["phone_number": "%2B1" + unformattedPhoneNumber], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company phone number has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
                    case .failure(let error):
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let updateButton = self?.updateButton else { return }
                UIHelper.enable(button: updateButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner(spinnerView: spinnerView)
            }
        }
    }
    
}

extension UpdateCompanyPhoneViewController {
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
