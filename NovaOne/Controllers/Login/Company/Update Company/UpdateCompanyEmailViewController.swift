//
//  UpdatePropertyEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyEmailViewController: UpdateBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: NovaOneTextField!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailTextField.becomeFirstResponder()
    }
    
    func setupUpdateButton() {
        // Setup update button
        UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    func setupTextField() {
        // Setup the text field
        self.emailTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func emailTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.emailTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = emailTextField.text else { return }
        
        // If email is valid, proceed to the next view
        if InputValidators.isValidEmail(email: updateValue) {
           guard
               let objectId = (self.updateObject as? Company)?.id,
               let detailViewController = self.detailViewController as? CompanyDetailViewController
            else { return }
           
           let updateClosure = {
               (company: Company) in
               company.email = updateValue
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
           
           self.updateObject(for: "property_company", at: ["email": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, successSubtitle: "Company email has been successfully updated.", successDoneHandler: successDoneHandler)
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
