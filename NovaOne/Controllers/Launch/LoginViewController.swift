//
//  LoginViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/28/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: NovaOneButton!
    let coreDataCustomerEmail: String? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first?.email
    let alertService = AlertService()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextFields()
        self.setupLoginButton()
        self.authenticateUsingBiometrics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Rotate the orientation of the screen to potrait and lock it
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset lock orientation to all so that if naviagting to another view,
        // you can rotate the orientation again
        AppUtility.lockOrientation(.all)
    }
    
    func setupTextFields() {
        // Set delegates for each text field so we can use the delegate methods for each text field
        self.passwordTextField.delegate = self
        self.userNameTextField.delegate = self
    }
    
    func setupLoginButton() {
        // Set up the login button
        // Disable continue button and only enable it when the user starts typing into one of the text fields
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = Defaults.novaOneColorDisabledColor
    }
    
    func authenticateUsingBiometrics() {
        
        // Check if user has username and password in keychain already
        // If they have a keychain credentials, then login to server using keychain credentials
        // on successful biometric authentication
        if let keychainEmail = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.email.rawValue),
            let keychainPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue) {
            
            let authContext = LAContext()
            let authReason = "Authenticate to access your NovaOne account."
            var authError: NSError? // Handle errors for touch id
            
            // Check if user has biometric authentication enabled
            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                
                authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason) { (success, error) in
                    
                    if success {
                        
                        DispatchQueue.main.async { // Go back to the main thread to deal with UI code
                            self.tabBarController?.selectedIndex = 2
                            
                            // Set text fields to have credentials on successful authentication
                            self.userNameTextField.text = keychainEmail
                            self.passwordTextField.text = keychainPassword
                            
                            // Login
                            self.formDataLogin(email: keychainEmail, password: keychainPassword)
                            
                        }
                        
                    } else {
                        
                        // User has biometric authentication but could not be autheticated due to some error
                        if let unwrappedError = error {
                            
                            DispatchQueue.main.async {
                                
                                // Print the error on why biometric authentication failed
                                print(unwrappedError.localizedDescription)
                                
                                // Pop up keyboard for username field if biometrics fails
                                self.userNameTextField.becomeFirstResponder()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                // Error with biometrics (not set up, user does not have biometric authentication, etc.)
                // Pop up keyboard for username field since they can not login via biometric authentication
                if let unwrappedAuthError = authError {
                    print(unwrappedAuthError.localizedDescription)
                    self.userNameTextField.becomeFirstResponder()
                }
                
            }
            
        } else {
            
            // Pop up keyboard for username field if no keychain credentials exist
            print("No keychain credentials found")
            self.userNameTextField.becomeFirstResponder()
            
        }
        
    }
    
    func navigateToLoginScreenAndSaveData(customer: CustomerModel, spinnerView: UIView) {
        // Navigate to login screen and save data to CoreData
        
        // Get non optionals from CustomerModel instance
        let dateJoinedDate = customer.dateJoinedDate
        let id = Int32(customer.id)
        let userId = Int32(customer.userId)
        let customerType = customer.customerType
        let email = customer.email
        let firstName = customer.firstName
        let isPaying = customer.isPaying
        let lastName = customer.lastName
        let phoneNumber = customer.phoneNumber
        let wantsEmailNotifications = customer.wantsEmailNotifications
        let wantsSms = customer.wantsSms
        let username = customer.username
        let password = customer.password
        let lastLoginDate = customer.lastLoginDate
        
        guard let coreDataCustomerObject = NSEntityDescription.insertNewObject(forEntityName: Defaults.CoreDataEntities.customer.rawValue, into: PersistenceService.context) as? Customer else { return }
        
        coreDataCustomerObject.addCustomer(customerType: customerType, dateJoined: dateJoinedDate, email: email, firstName: firstName, id: id, userId: userId, isPaying: isPaying, lastName: lastName, phoneNumber: phoneNumber, wantsSms: wantsSms, wantsEmailNotifications: wantsEmailNotifications, password: password, username: username, lastLogin: lastLoginDate, companies: nil)
        
        // Save to CoreData
        PersistenceService.saveContext()
        
        // Save logged in status to UserDefaults
        UserDefaults.standard.set(true, forKey: Defaults.UserDefaults.isLoggedIn.rawValue)
        UserDefaults.standard.synchronize()
        
        // Get container view controller
        guard let containerViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.container.rawValue) as? ContainerViewController else { print("could not get container view controller - home view controller"); return }
        
        // Present container view controller
        containerViewController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
        self.present(containerViewController, animated: true, completion: {
            self.removeSpinner(spinnerView: spinnerView)
        })
    }
    
    // Sends a post request using url encoded string
    func formDataLogin(email: String, password: String) {
        
        // Show spinner
        let spinnerView = self.showSpinner(for: self.view, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        let parameters: [String: Any] = ["email": email, "password": password]
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/login.php", dataModel: CustomerModel.self, parameters: parameters) {
            [weak self] (result) in
            
            // Use a switch statement to go through the cases of the Result eumeration
            // and to access the associated values for each enumeration case
            switch result {
                
                case .success(let customer):
                    
                    // Add username and password to keychain if not already in Keychain and if there is a new email used for logging in
                    let keychainEmail = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.email.rawValue) != nil ? KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.email.rawValue)! : ""
                    let keychainPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue) != nil ? KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)! : ""
                    
                    if keychainEmail.isEmpty || keychainPassword.isEmpty || email != keychainEmail || password != keychainPassword {
                        let title = "Add To Keychain"
                        let body = "Would you like to add your email and password to Keychain for easier sign in?"
                        guard let popUpActionViewController = self?.alertService.popUp(title: title, body: body, buttonTitle: "Yes", actionHandler: {
                            
                            // Save to keychain
                            KeychainWrapper.standard.set(email, forKey: Defaults.KeychainKeys.email.rawValue)
                            KeychainWrapper.standard.set(password, forKey: Defaults.KeychainKeys.password.rawValue)
                            
                            self?.getCompanies(customer: customer, spinnerView: spinnerView) {
                                self?.navigateToLoginScreenAndSaveData(customer: customer, spinnerView: spinnerView)
                            }
                            
                        }, cancelHandler: {
                            self?.getCompanies(customer: customer, spinnerView: spinnerView) {
                                self?.navigateToLoginScreenAndSaveData(customer: customer, spinnerView: spinnerView)
                            }
                        }) else { return }

                        self?.present(popUpActionViewController, animated: true, completion: nil)
                        
                    } else {
                        self?.getCompanies(customer: customer, spinnerView: spinnerView) {
                            self?.navigateToLoginScreenAndSaveData(customer: customer, spinnerView: spinnerView)
                        }
                    }
                   
                
                case .failure(let error):
                    // Show error message with a pop up and enable continue button
                    
                    DispatchQueue.main.async {
                        self?.removeSpinner(spinnerView: spinnerView)
                        // Set text for pop up ok view controller
                        let title = "Error"
                        let body = error.localizedDescription
                        
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: title, body: body) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                        
                        self?.loginButton.isEnabled = true
                        self?.loginButton.backgroundColor = Defaults.novaOneColor
                    }
                
            }
            
        }
        
    }
    
    func getCompanies(customer: CustomerModel, spinnerView: UIView, success: @escaping () -> Void) {
        // Gets company data belonging to the customer
        
        // Delete all old companies from Core Data
        PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.customer.rawValue) // Need to delete customer object first because Core Data won't let us delete customer objects since they share a relationship
        PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.company.rawValue)
        
        let httpRequest = HTTPRequests()
        guard
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let email = customer.email
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/companies.php", dataModel: [CompanyModel].self, parameters: parameters) {
            (result) in
            
            switch result {
                case .success(let companies):
                    for company in companies {
                        
                        // Save to CoreData
                        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: PersistenceService.context) else { return }
                        
                        if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
                            coreDataCompany.address = company.address
                            coreDataCompany.city = company.city
                            coreDataCompany.state = company.state
                            coreDataCompany.zip = company.zip
                            coreDataCompany.allowSameDayAppointments = company.allowSameDayAppointments
                            coreDataCompany.created = company.createdDate
                            coreDataCompany.autoRespondNumber = company.autoRespondNumber
                            coreDataCompany.autoRespondText = company.autoRespondText
                            coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
                            coreDataCompany.email = company.email
                            coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
                            coreDataCompany.id = Int32(company.id)
                            coreDataCompany.name = company.name
                            coreDataCompany.phoneNumber = company.phoneNumber
                            coreDataCompany.shortenedAddress = company.shortenedAddress
                        }
                        
                    }
                
                    PersistenceService.saveContext()
                    success()
                
                case .failure(let error):
                    self.removeSpinner(spinnerView: spinnerView)
                    let popUpOkViewController = self.alertService.popUpOk(title: "Data Failure", body: "Failed to obtain company data.")
                    self.present(popUpOkViewController, animated: true, completion: nil)
                    print(error.localizedDescription)
            }
            
        }
    }
    
    // MARK: Actions
    // Cancel button touched
    @IBAction func cancelButtonTouch(_ sender: UIButton) {
        
        // Remove the modal popup view on touch of the cancel 'x' button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    // Login button touched
    @IBAction func loginButtonTouch(_ sender: NovaOneButton) {
        
        guard
            let email = self.userNameTextField.text,
            let password = self.passwordTextField.text
        else { return }
        
        // Disable button to prevent multiple requests
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = Defaults.novaOneColorDisabledColor
        
        self.formDataLogin(email: email, password: password)
        
    }
    
    
    
    
    
    // Username field editing changed
    @IBAction func usernameEditingChanged(_ sender: Any) {
        UIHelper.toggle(button: self.loginButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) { () -> Bool in
            
            guard
                let username = self.userNameTextField.text,
                let password = self.passwordTextField.text
            else { return false }
            
            if username.isEmpty || password.isEmpty {
                return false
            }
            
            return true
            
        }
    }
    
    // Password field editing changed
    @IBAction func passwordEditingChanged(_ sender: Any) {
        UIHelper.toggle(button: self.loginButton, textField: nil, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false) { () -> Bool in
            
            guard
                let username = self.userNameTextField.text,
                let password = self.passwordTextField.text
            else { return false }
            
            if username.isEmpty || password.isEmpty {
                return false
            }
            
            return true
            
        }
    }

}

extension LoginViewController {
    
    
    // This function is called every time the return key is pressed on the keyboard if delegates are set for each UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            // Send touch event to the login button so that our data validation logic can be used
            self.loginButton.sendActions(for: .touchUpInside)
        } else {
            // Set keyboard for password text field when the return key ('go' key in our case) is pressed
            self.passwordTextField.becomeFirstResponder()
        }
        
        return true
        
    }
    
}
