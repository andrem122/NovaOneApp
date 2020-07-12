//
//  UpdateLeadEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadEmailViewController: UpdateBaseViewController {
    
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
    
    // MARK: Actions
    @IBAction func emailTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.emailTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = emailTextField.text?.trim() else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: updateValue) {
           guard
               let objectId = (self.updateObject as? Lead)?.id,
               let detailViewController = self.previousViewController as? LeadDetailViewController
            else { return }
           
           let updateClosure = {
               (lead: Lead) in
               lead.email = updateValue
           }
           
           let successDoneHandler = {
               [weak self] in
               
               let predicate = NSPredicate(format: "id == %@", String(objectId))
               guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
               
               detailViewController.lead = updatedLead
               detailViewController.setupObjectDetailCellsAndTitle()
               detailViewController.objectDetailTableView.reloadData()
               
               self?.removeSpinner()
               
           }
           
            self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["email": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, successSubtitle: "Lead email has been successfully updated.", successDoneHandler: successDoneHandler)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension UpdateLeadEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
