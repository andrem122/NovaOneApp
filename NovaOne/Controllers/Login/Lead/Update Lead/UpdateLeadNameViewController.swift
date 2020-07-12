//
//  UpdateLeadNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadNameViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var nameTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.nameTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = self.nameTextField.text else { return }
        if updateValue.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Enter Name", body: "Please enter a name.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard
                let objectId = (self.updateObject as? Lead)?.id,
                let previousViewController = self.previousViewController as? LeadDetailViewController
            else { return }
            
            let updateClosure = {
                (lead: Lead) in
                lead.name = updateValue
            }
            
            let successDoneHandler = {
                [weak self] in
                
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
                
                previousViewController.lead = updatedLead
                previousViewController.setupObjectDetailCellsAndTitle()
                previousViewController.objectDetailTableView.reloadData()
                
                self?.removeSpinner()
                
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["name": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, successSubtitle: "Name has been successfully updated.", successDoneHandler: successDoneHandler)
        }
    }
    
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.nameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
}
