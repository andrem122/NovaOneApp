//
//  SignUpEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpEmailViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // MARK: Methods
    func setup() {
        self.emailAddressTextField.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        self.emailAddressTextField.becomeFirstResponder() // Make text field become first responder
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Dismiss this view controller on tap of the cancel button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let email = emailAddressTextField.text else { return }
        
        // If email is valid, check for it in the database before continuing
        if InputValidators.isValidEmail(email: email) {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            self.showSpinner(for: self.view, textForLabel: "Validating Email")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": email, "tableName": "auth_user", "columnName": "email"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(let success):
                    
                    print(success.successReason)
                    self?.customer = CustomerModel(id: 0, password: "", lastLogin: "", username: email, firstName: "", lastName: "", email: email, dateJoined: "", isPaying: false, wantsSms: false, phoneNumber: "", customerType: "")
                    guard let signUpPasswordViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpPassword.rawValue) as? SignUpPasswordViewController else { return }
                    signUpPasswordViewController.customer = self?.customer
                    self?.navigationController?.pushViewController(signUpPasswordViewController, animated: true)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let button = self?.continueButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner()
            }
        } else {
            // Email is not valid, so present pop up
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Email", body: "Please enter a valid email.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func emailFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.emailAddressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
    }
    
}

extension SignUpEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.continueButton.sendActions(for: .touchUpInside)
        return true
    }
}
