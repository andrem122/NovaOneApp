//
//  SignUpEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class SignUpEmailViewController: BaseSignUpViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var privacyPolicyTextView: UITextView!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpEmail.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpEmail.rawValue
        
        let textFieldText = self.emailAddressTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? true ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpEmail.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func setupTextField() {
        // Set delegates
        self.emailAddressTextField.delegate = self
    }
    
    func setupPrivacyPolicyTextView() {
        // Sets up the privacy policy text view
        self.privacyPolicyTextView.delegate = self
        self.privacyPolicyTextView.isEditable = false
        
        let privacyPolicyString = "For more information, please see our privacy policy"
        let range = NSRange(location: 37, length: 14) // String starts at index 37 and is 14 characters long, which are the words "privacy policy"
        let attributedString = NSMutableAttributedString(string: privacyPolicyString)
        attributedString.addAttribute(.link, value: Defaults.Urls.novaOneWebsite.rawValue + "/privacy-policy", range: range)
        
        let colorAttribute = [NSAttributedString.Key.foregroundColor: UIColor.red]
        attributedString.addAttributes(colorAttribute, range: range)
        
        var fontSizeAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSizeAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]
        }
        attributedString.addAttributes(fontSizeAttribute, range: NSRange(location: 0, length: privacyPolicyString.count))
        
        self.privacyPolicyTextView.attributedText = attributedString
        self.privacyPolicyTextView.textAlignment = .center
        self.privacyPolicyTextView.textColor = UIColor(named: Defaults.Colors.text.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restore(textField: self.emailAddressTextField, continueButton: self.continueButton, coreDataEntity: Customer.self) { (customer) -> String in
            guard let customer = customer as? Customer else { return "" }
            guard let email = customer.email else { return "" }
            return email
        }
        self.setupTextField()
        self.setupPrivacyPolicyTextView()
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
            let spinnerView = self.showSpinner(for: self.view, textForLabel: "Validating Email")
            
            let httpRequest = HTTPRequests()
            let parameters: [String: String] = ["valueToCheckInDatabase": email, "tableName": Defaults.DataBaseTableNames.authUser.rawValue, "columnName": "email"]
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/inputCheck.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                case .success(let success):
                    print(success.successReason)
                    
                    // Create core data customer object or get it if it already exists for state restoration
                    let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.customer.rawValue)
                    if count == 0 {
                        guard let coreDataCustomerObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.customer.rawValue, into: PersistenceService.context) as? Customer else { return }
                        
                        coreDataCustomerObject.addCustomer(customerType: "", dateJoined: Date(), email: email, firstName: "", id: 0, userId: 0, isPaying: false, lastName: "", phoneNumber: "", wantsSms: false, wantsEmailNotifications: false, password: "", username: email, lastLogin: Date(), companies: nil)
                    } else {
                        // Get existing core data object and update it
                        // NOTE: Will not find core data object if user has already signed in and has a customer core data
                        // object with an id greater than zero
                        let filter = NSPredicate(format: "id == %@", "0")
                        guard let coreDataCustomerObject = PersistenceService.fetchEntity(Customer.self, filter: filter, sort: nil).first else {
                            print("could not get coredata customer object - Sign Up Email View Controller")
                            self?.removeSpinner(spinnerView: spinnerView)
                            return
                        }
                        coreDataCustomerObject.email = email
                    }
                    
                    // Save to CoreData for state restoration
                    PersistenceService.saveContext(context: nil)
                    
                    guard let signUpPasswordViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpPassword.rawValue) as? SignUpPasswordViewController else { return }
                    self?.navigationController?.pushViewController(signUpPasswordViewController, animated: true)
                    
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                guard let button = self?.continueButton else { return }
                UIHelper.enable(button: button, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
                self?.removeSpinner(spinnerView: spinnerView)
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
