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
    lazy var alert: Alert = Alert(currentViewController: self)
    
    // MARK: Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setUpGeneric()
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
    
    func setUpGeneric() {
        
        // Set delegates for each text field so we can use the delegate methods for each text field
        self.passwordTextField.delegate = self
        self.userNameTextField.delegate = self
        
        // Disable continue button and only enable it when the user starts typing into one of the text fields
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = Defaults.novaOneColorDisabledColor
        
    }
    
    // Toggles the login button from between disabled and enabled states
    // based on email text field value
    func toggleLoginButton() {
        
        guard
            let email = self.userNameTextField.text
        else { return }
        
        if email.isEmpty {
            
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = Defaults.novaOneColorDisabledColor
            
        } else {
            
            self.loginButton.isEnabled = true
            self.loginButton.backgroundColor = Defaults.novaOneColor
            
        }
        
    }
    
    
    func authenticateUsingBiometrics() {
        
        // Check if user has username and password in keychain already
        // If they have a keychain credentials, then login to server using keychain credentials
        // on successful biometric authentication
        if let keychainUsername = KeychainWrapper.standard.string(forKey: "username"),
            let keychainPassword = KeychainWrapper.standard.string(forKey: "password") {
            
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
                            self.userNameTextField.text = keychainUsername
                            self.passwordTextField.text = keychainPassword
                            
                            self.formDataLogin(username: keychainUsername, password: keychainPassword)
                            
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
    
    // Sends a post request using url encoded string
    func formDataLogin(username: String, password: String) {
        
        let httpRequest = HTTPRequests()
        let parameters: [String: Any] = ["email": username, "password": password]
        httpRequest.request(endpoint: "/login.php", dataModel: CustomerModel(id: 1), parameters: parameters) { [weak self] (result) in
            
            // Use a switch statement to go through the cases of the Result eumeration
            // and to access the associated values for each enumeration case
            switch result {
                
                // If the result is successful, we will get the customer object we passed into the
                // result enum and move on to the next view
                case .success(let customer):
                    // Add username and password to keychain if the username and password is correct
                    KeychainWrapper.standard.set(username, forKey: "username")
                    KeychainWrapper.standard.set(password, forKey: "password")
                    
                    // Go to tab bar view controller
                    if let tabBarViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.TabControllerIdentifiers.home.rawValue) as? HomeTabBarController  {
                        
                        // Unwrap optionals from CustomerModel instance
                        guard
                            let companyAddress = customer.companyAddress,
                            let companyEmail = customer.companyEmail,
                            let companyId = customer.companyId,
                            let companyName = customer.companyName,
                            let companyPhone = customer.companyPhone,
                            let customerType = customer.customerType,
                            let daysOfTheWeekEnabled = customer.daysOfTheWeekEnabled,
                            let email = customer.email,
                            let firstName = customer.firstName,
                            let hoursOfTheDayEnabled = customer.hoursOfTheDayEnabled,
                            let isPaying = customer.isPaying,
                            let lastName = customer.lastName,
                            let phoneNumber = customer.phoneNumber,
                            let wantsSms = customer.wantsSms
                        else { return }
                        
                        // Get non optionals from CustomerModel instance
                        let dateJoinedDate = customer.dateJoinedDate
                        let id = customer.id
                        
                        // If there are no customer CoreData objects, save the new customer object
                        // else get and update the existing customer object
                        let customerCount = PersistenceService.entityExists(entityName: "Customer")
                        if customerCount == 0 {
                            // Save customer object to CoreData IF they are NOT already saved to CoreData
                            let coreDataCustomer = Customer(context: PersistenceService.context)
                            coreDataCustomer.id = Int32(id)
                            coreDataCustomer.companyAddress = companyAddress
                            coreDataCustomer.companyEmail = companyEmail
                            coreDataCustomer.companyId = Int32(companyId)
                            coreDataCustomer.companyName = companyName
                            coreDataCustomer.companyPhone = companyPhone
                            coreDataCustomer.customerType = customerType
                            coreDataCustomer.daysOfTheWeekEnabled = daysOfTheWeekEnabled
                            coreDataCustomer.email = email
                            coreDataCustomer.firstName = firstName
                            coreDataCustomer.hoursOfTheDayEnabled = hoursOfTheDayEnabled
                            coreDataCustomer.isPaying = isPaying
                            coreDataCustomer.lastName = lastName
                            coreDataCustomer.phoneNumber = phoneNumber
                            coreDataCustomer.wantsSms = wantsSms
                            coreDataCustomer.dateJoined = dateJoinedDate
                            
                            PersistenceService.saveContext()
                        } else {
                            guard let coreDataCustomer = PersistenceService.fetchCustomerEntity() else { return }
                            coreDataCustomer.id = Int32(id)
                            coreDataCustomer.companyAddress = companyAddress
                            coreDataCustomer.companyEmail = companyEmail
                            coreDataCustomer.companyId = Int32(companyId)
                            coreDataCustomer.companyName = companyName
                            coreDataCustomer.companyPhone = companyPhone
                            coreDataCustomer.customerType = customerType
                            coreDataCustomer.daysOfTheWeekEnabled = daysOfTheWeekEnabled
                            coreDataCustomer.email = email
                            coreDataCustomer.firstName = firstName
                            coreDataCustomer.hoursOfTheDayEnabled = hoursOfTheDayEnabled
                            coreDataCustomer.isPaying = isPaying
                            coreDataCustomer.lastName = lastName
                            coreDataCustomer.phoneNumber = phoneNumber
                            coreDataCustomer.wantsSms = wantsSms
                            coreDataCustomer.dateJoined = dateJoinedDate
                            
                            PersistenceService.saveContext()
                        }
                        
                        tabBarViewController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
                        self?.present(tabBarViewController, animated: true, completion: nil)
                        
                    }
                
                case .failure(let error):
                    // Show error message with an alert and enable continue button
                    self?.alert.alertMessage(title: "Error", message: error.localizedDescription)
                    self?.loginButton.isEnabled = true
                    self?.loginButton.backgroundColor = Defaults.novaOneColor
                
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
        
        // Check if fields are empty before proceeding to log in user
        // Input field text
        guard // unwrap optionals safely
            let username = self.userNameTextField.text,
            let password = self.passwordTextField.text
        else { return }
        
        // If user name or password field is empty, alert the user with a message and exit the function
        if username.isEmpty {
            
            alert.alertMessage(title: "Email Required", message: "Email: This field is required.")
            return
            
        } else if password.isEmpty {
            
            alert.alertMessage(title: "Password Required", message: "Password: This field is required.")
            return

        }
        
        // Disable button to prevent multiple requests
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = Defaults.novaOneColorDisabledColor
        
        // Proceed with logging the user in if text fields are not empty
        self.formDataLogin(username: username, password: password)
        
    }
    
    
    
    
    
    // Username field editing changed
    @IBAction func usernameEditingChanged(_ sender: Any) {
        
        self.toggleLoginButton()
        
    }
    
    // Password field editing changed
    @IBAction func passwordEditingChanged(_ sender: Any) {
        
        self.toggleLoginButton()
        
    }
    


    // MARK: - Navigation

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }*/

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
