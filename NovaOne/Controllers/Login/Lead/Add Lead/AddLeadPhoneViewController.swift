//
//  AddLeadPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadPhoneViewController: AddLeadBaseViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var phoneNumberTextField: NovaOneTextField!
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        self.setupContinueButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    func setupTextField() {
        // Set up the text field
        self.phoneNumberTextField.delegate = self
    }
    
    func setupContinueButton() {
        // Setup the continue button
        
        // Set title based on customer type
        guard let customerType = self.customer?.customerType else { return }
        if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            self.continueButton.setTitle("Add Lead", for: .normal)
        }
        
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    // MARK: Actions
    @IBAction func phoneNumberTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.phoneNumberTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Go to renter brand view IF the customer is of type property manager or 'PM'
        // else make a POST request
        guard let customerType = self.customer?.customerType else { return }
        
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            guard let addLeadRenterBrandViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadRenterBrand.rawValue) as? AddLeadRenterBrandViewController else { return }
            
            guard let phoneNumber = self.phoneNumberTextField.text else { return }
            let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
            
            self.lead?.phoneNumber = "%2B1" + unformattedPhoneNumber
            addLeadRenterBrandViewController.lead = self.lead
            addLeadRenterBrandViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addLeadRenterBrandViewController, animated: true)
        } else {
            
            self.showSpinner(for: self.view, textForLabel: "Adding Lead...")
            
            // Get data for POST parameters
            guard
                let name = self.lead?.name,
                let email = self.lead?.email,
                let companyId = self.lead?.companyId,
                let phoneNumber = self.phoneNumberTextField.text,
                let renterBrand = self.lead?.renterBrand,
                let customerEmail = self.customer?.email,
                let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
                let customerUserId = self.customer?.id
                else { return }
            let dateOfInquiry = DateHelper.createString(from: Date(), format: "yyyy-MM-dd HH:mm:ssZ")
            let unformattedPhoneNumber = "%2B1" + phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
            
            let parameters: [String: String] = ["customerUserId": String(customerUserId), "email": customerEmail, "password": customerPassword, "leadName": name, "leadPhoneNumber": unformattedPhoneNumber, "leadEmail": email, "leadRenterBrand": renterBrand, "dateOfInquiry": dateOfInquiry, "leadCompanyId": String(companyId)]
            
            let httpRequest = HTTPRequests()
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/addLead.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                    case .success(let success):
                        // Redirect to success screen
                        
                        self?.removeSpinner()
                        
                        let popupStoryboard = UIStoryboard(name: Defaults.StoryBoards.popups.rawValue, bundle: .main)
                        guard let successViewController = popupStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                        successViewController.subtitleText = success.successReason
                        successViewController.titleLabelText = "Lead Added!"
                        successViewController.doneHandler = {
                            [weak self] in
                            // Return to the appointments view and refresh appointments
                            self?.presentingViewController?.dismiss(animated: true, completion: nil)
                            
                            // The embedded view controller in the container view controller is either
                            // the empty view controller or the table view controller
                            if let emptyViewController = self?.embeddedViewController as? EmptyViewController {
                                emptyViewController.refreshButton.sendActions(for: .touchUpInside)
                            } else {
                                print("leads view controller")
                                guard let leadsTableViewController = self?.embeddedViewController as? LeadsTableViewController else { return }
                                leadsTableViewController.refreshDataOnPullDown()
                            }
                        }
                        self?.present(successViewController, animated: true, completion: nil)
                    case .failure(let error):
                        self?.removeSpinner()
                        guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOk, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension AddLeadPhoneViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var phoneNumber = textField.text else { return false }
        UIHelper.toggle(button: self.continueButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil) {() -> Bool in
            
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
