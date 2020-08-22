//
//  UpdatePropertyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyNameViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var companyNameTextField: NovaOneTextField!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.companyNameTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.companyNameTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    @IBAction func companyNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.companyNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateValue = self.companyNameTextField.text != nil ? self.companyNameTextField.text!.trim() : ""
        if updateValue.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Enter Name", body: "Enter a company name.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { return }
            
            let updateClosure = {
                (company: Company) in
                company.name = updateValue
            }
            
            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { print("error getting updated company"); return }
                
                detailViewController.coreDataObjectId = updatedCompany.id
                detailViewController.setupObjectDetailCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["name": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company name has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
        }
        
    }
    
}

extension UpdateCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButton.sendActions(for: .touchUpInside)
        return true
    }
}
