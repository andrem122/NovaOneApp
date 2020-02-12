//
//  LoginViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/28/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: NovaOneButton!
    
    lazy var alert: Alert = Alert(currentViewController: self)
    let loginUrl: String = "https://graystonerealtyfl.com/NovaOne"
    let disabledButtonColor: UIColor = UIColor(red: 82/255, green: 107/255, blue: 217/255, alpha: 0.3) // Must divide by 255 because swift rgba arguments take a number between 0 and 1
    let enabledButtonColor: UIColor = UIColor(red: 82/255, green: 107/255, blue: 217/255, alpha: 1)
    var customer: CustomerModel?
    
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
        self.loginButton.backgroundColor = self.disabledButtonColor
        
    }
    
    // Toggles the login button from between disabled and enabled states
    // based on email text field value
    func toggleLoginButton() {
        
        guard
            let email = self.userNameTextField.text
        else { return }
        
        if email.isEmpty {
            
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = self.disabledButtonColor
            
        } else {
            
            self.loginButton.isEnabled = true
            self.loginButton.backgroundColor = self.enabledButtonColor
            
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
    
    func formDataLogin(username: String, password: String) {
        
        let httpRequest = HTTPRequests(url: self.loginUrl)
        let parameters: [String: Any] = ["PHPAuthenticationUsername": Defaults().PHPAuthenticationUsername, "PHPAuthenticationPassword": Defaults().PHPAuthenticationPassword, "email": username, "password": password]
        httpRequest.request(endpoint: "/login.php", parameters: parameters) { [weak self] (result) in
            
            // Use a switch statement to go through the cases of the Result eumeration
            // and to access the associated values for each enumeration case
            switch result {
                
                // If the result is successful, we will get the customer object we passed into the
                // result enum and move on to the next view
                case .success(let customer):
                    // Add username and password to keychain if the username and password is correct
                    KeychainWrapper.standard.set(username, forKey: "username")
                    KeychainWrapper.standard.set(password, forKey: "password")
                    
                    // Go to the home view controller
                    if let homeViewController = self?.storyboard?.instantiateViewController(identifier: "homeViewController") as? HomeViewController  {
                        
                        let menuNavigationController = UINavigationController(rootViewController: homeViewController)
                        homeViewController.customer = customer
                        menuNavigationController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
                        self?.present(menuNavigationController, animated: true, completion: nil)
                        
                    }
                
                case .failure(let error):
                    // Show error message with an alert and enable continue button
                    self?.alert.alertMessage(title: "Error", message: error.localizedDescription)
                    self?.loginButton.isEnabled = true
                    self?.loginButton.backgroundColor = self?.enabledButtonColor
                
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
        self.loginButton.backgroundColor = self.disabledButtonColor
        
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
