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
        
        // Rotate the orientation of the screen to potrait and lock it
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
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
        
        // Allow all orientaions after cancel button is tapped
        AppUtility.lockOrientation(.all)
    }
    
    
    @IBAction func companyNameTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.companyNameTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Get name from text field
        guard
            let companyName = self.companyNameTextField.text
        else { return }
        
        if companyName.isEmpty {
            let title = "Company Name"
            let body = "Please type in a name for your company."
            let popUpOkViewCOntroller = self.alertService.popUpOk(title: title, body: body)
            self.present(popUpOkViewCOntroller, animated: true, completion: nil)
        } else {
            guard
                let addCompanyAddressViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyAddress.rawValue) as? AddCompanyAddressViewController,
                let customerUserId = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first?.id
            else { return }
            
            addCompanyAddressViewController.company = CompanyModel(id: 0, name: companyName, address: "", phoneNumber: "", autoRespondNumber: nil, autoRespondText: nil, email: "", created: "", allowSameDayAppointments: false, daysOfTheWeekEnabled: "", hoursOfTheDayEnabled: "", city: "", customerUserId: Int(customerUserId), state: "", zip: "")
            addCompanyAddressViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addCompanyAddressViewController, animated: true)
        }
        
    }
    
}

extension AddCompanyNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
