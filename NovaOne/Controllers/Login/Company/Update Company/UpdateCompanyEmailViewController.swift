//
//  UpdatePropertyEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyEmailViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    
    // MARK: Methods
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
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { return }
           
           let updateClosure = {
               (company: Company) in
               company.email = updateValue
           }
           
           let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { return }
            detailViewController.company = updatedCompany
            detailViewController.coreDataObjectId = objectId
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
           }
           
            self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["email": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company email has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
}

extension UpdateCompanyEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
