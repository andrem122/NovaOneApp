//
//  AddCompanyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyNameViewController: AddCompanyBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var companyNameTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTextField()
        self.setupContinueButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.companyNameTextField.becomeFirstResponder()
    }
    
    func setupTextField() {
        // Setup the text field
        self.companyNameTextField.delegate = self
    }
    
    func setupContinueButton() {
        // Setup the continue button
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func companyNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.companyNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let addCompanyAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyAddress.rawValue) as? AddCompanyAddressViewController else { print("could not get add company address view controller");return }
        
        // Get name from text field
        guard
            let companyName = self.companyNameTextField.text,
            let customerUserId = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first?.id
            else { print("could not get variables"); return }
        
        addCompanyAddressViewController.company = CompanyModel(id: 0, name: companyName, address: "", phoneNumber: "", autoRespondNumber: nil, autoRespondText: nil, email: "", created: "", allowSameDayAppointments: false, daysOfTheWeekEnabled: "", hoursOfTheDayEnabled: "", city: "", customerUserId: Int(customerUserId), state: "", zip: "")
        addCompanyAddressViewController.embeddedViewController = self.embeddedViewController
        
        self.navigationController?.pushViewController(addCompanyAddressViewController, animated: true)
    }
    
}

extension AddCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
