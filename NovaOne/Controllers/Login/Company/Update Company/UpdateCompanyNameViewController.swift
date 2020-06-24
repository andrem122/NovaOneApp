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
        self.setupUpdateButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.companyNameTextField.becomeFirstResponder()
    }
    
    func setupUpdateButton() {
        // Setup update button
        UIHelper.disable(button: self.updateButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    // MARK: Actions
    @IBAction func companyNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.companyNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let updateValue = self.companyNameTextField.text,
            let objectId = (self.updateObject as? Company)?.id,
            let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { print("error getting detail view controller"); return }
        
        let updateClosure = {
            (company: Company) in
            company.name = updateValue
        }
        
        let successDoneHandler = {
            [weak self] in
            
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { print("error getting updated company"); return }
            
            detailViewController.company = updatedCompany
            detailViewController.setupCompanyCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
            
            self?.removeSpinner()
            
        }
        
        self.updateObject(for: "property_company", at: ["name": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, successSubtitle: "Company name has been successfully updated.", successDoneHandler: successDoneHandler)
    }
    
}
