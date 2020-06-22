//
//  UpdatePropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyPhoneViewController: UpdateBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var phoneNumberTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        self.setupUpdateButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    func setupTextField() {
        self.phoneNumberTextField.delegate = self
    }
    
    func setupUpdateButton() {
        UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    // MARK: Actions
    @IBAction func phoneNumberTextFieldChanged(_ sender: Any) {
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let updateValue = self.phoneNumberTextField.text,
            let objectId = (self.updateObject as? Company)?.id,
            let detailViewController = self.detailViewController as? CompanyDetailViewController
            else { return }
        
        let updateClosure = {
            (company: Company) in
            company.phoneNumber = updateValue
        }
        
        let successDoneHandler = {
            [weak self] in
            
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { return }
            
            detailViewController.company = updatedCompany
            detailViewController.setupCompanyCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
            
            self?.removeSpinner()
            
        }
        
        self.updateObject(for: "property_company", at: ["phone_number": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, successSubtitle: "Company phone number has been successfully updated.", successDoneHandler: successDoneHandler)
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
