//
//  SignUpPropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCompanyPhoneViewController: BaseSignUpViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var propertyPhoneTextField: NovaOneTextField!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue
        
        let textFieldText = self.propertyPhoneTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? true ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func setupTextField() {
        self.propertyPhoneTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restore(textField: self.propertyPhoneTextField, continueButton: self.continueButton, coreDataEntity: Company.self) { (company) -> String in
            guard let company = company as? Company else { return "" }
            guard let phoneNumber = company.phoneNumber else { return "" }
            return phoneNumber
        }
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        // Make text field become first responder
        self.propertyPhoneTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all) // Reset orientation
    }
    
    // MARK: Actions
    @IBAction func propertyPhoneTextFieldChanged(_ sender: Any) {
        
        UIHelper.toggle(button: self.continueButton, textField: self.propertyPhoneTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
        
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Parameter values
        guard let phoneNumber = self.propertyPhoneTextField.text else { return }
        let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        
        if !unformattedPhoneNumber.isNumeric {
            let popUpOkViewController = self.alertService.popUpOk(title: "Invalid Number", body: "Please enter only numbers.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Disable button while doing HTTP request
            UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            let spinnerView = self.showSpinner(for: self.view, textForLabel: "Validating Phone Number")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": "+1" + unformattedPhoneNumber, "tableName": Defaults.DataBaseTableNames.company.rawValue, "columnName": "phone_number"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(_):
                    
                    let addCompanyStoryboard = UIStoryboard(name: Defaults.StoryBoards.addCompany.rawValue, bundle: .main)
                    guard
                        let addCompanyAllowSameDayAppointmentsViewController = addCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue) as? AddCompanyAllowSameDayAppointmentsViewController
                    else { return }
                    
                    addCompanyAllowSameDayAppointmentsViewController.userIsSigningUp = true // Indicates that the user is new and signing up and not an existing user adding a company
                    
                    // Get existing core data object and update it
                    let filter = NSPredicate(format: "id == %@", "0")
                    guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - Sign Up Company Phone View Controller"); return }
                    coreDataCompanyObject.phoneNumber = phoneNumber
                    
                    // Save to context
                    PersistenceService.saveContext(context: nil)
                    
                    self?.navigationController?.pushViewController(addCompanyAllowSameDayAppointmentsViewController, animated: true)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                self?.removeSpinner(spinnerView: spinnerView)
                guard let button = self?.continueButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
            }
        }
        
    }
    
}

extension SignUpCompanyPhoneViewController {
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
