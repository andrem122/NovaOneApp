//
//  UpdateLeadPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadPhoneViewController: UpdateBaseViewController {
    
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
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Parameter values
        guard let phoneNumber = self.phoneNumberTextField.text else { return }
        let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        if !unformattedPhoneNumber.isNumeric {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter only numbers.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Disable button while doing HTTP request
            guard
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? LeadDetailViewController
                else { return }

            let updateClosure = {
                (lead: Lead) in
                lead.phoneNumber = "+1" + unformattedPhoneNumber
            }

            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
                detailViewController.lead = updatedLead
                detailViewController.coreDataObjectId = objectId
                detailViewController.setupObjectDetailCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }

            self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["phone_number": "%2B1" + unformattedPhoneNumber], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Lead phone number has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
        }
    }
    
}

extension UpdateLeadPhoneViewController {
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
