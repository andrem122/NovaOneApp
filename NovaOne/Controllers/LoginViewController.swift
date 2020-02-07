//
//  LoginViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/28/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: NovaOneButton!
    
    lazy var alert: Alert = Alert(currentViewController: self)
    let disabledButtonColor: UIColor = UIColor(red: 82/255, green: 107/255, blue: 217/255, alpha: 0.3)
    let enabledButtonColor: UIColor = UIColor(red: 82/255, green: 107/255, blue: 217/255, alpha: 1)
    var customer: CustomerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpGeneric()
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
        
        // Pop up keyboard for username field as soon as view loads
        self.userNameTextField.becomeFirstResponder()
        
        // Set delegates for each text field so we can use the delegate methods for each text field
        self.passwordTextField.delegate = self
        self.userNameTextField.delegate = self
        
        // Disable continue button and only enable it when the user starts typing into one of the text fields
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = self.disabledButtonColor // Must divide by 255 because swift rgba arguments take a number between 0 and 1
        
    }
    
    // Toggles the login button from between disabled and enabled states
    // based on text field values
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
    
    // MARK: Methods
    func logIn(userName: String, password: String) {
        
        let url: String = "https://graystonerealtyfl.com/NovaOne"
        let httpRequest = HTTPRequests(url: url)
        let parameters: [String: Any] = ["PHPAuthenticationUsername": Defaults().PHPAuthenticationUsername, "PHPAuthenticationPassword": Defaults().PHPAuthenticationPassword, "email": userName, "password": password]
        httpRequest.request(endpoint: "/login.php", parameters: parameters) { (result) in
            print(result)
        }
//        httpRequest.post(parameters: parameters) {
//            (responseString, data) in
//
//            // Go to the userLoggedInStart view if POST request returns a json data object
//            // (means login attempt was successful) else pop up an alert with the error message
//            // from the PHP script
//            if let jsonData = data {
//
//                let decoder = JSONDecoder()
//                let customer = try! decoder.decode(CustomerModel.self, from: jsonData) // convert json data to customer object
//                self.customer = customer
//
//                DispatchQueue.main.async {
//
//                    // When you get a view controller by its storyboard ID, it forget that
//                    // the view controller is embedded in anything. So swift will forget
//                    // that we embedded the home view controller in a navigation controller
//                    // The fix for this is below.
//                    if let homeViewController = self.storyboard?.instantiateViewController(identifier: "homeViewController") as? HomeViewController  {
//
//                        let menuNavigationController = UINavigationController(rootViewController: homeViewController)
//                        homeViewController.customer = self.customer
//                        menuNavigationController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
//                        self.present(menuNavigationController, animated: true, completion: nil)
//
//                    }
//                }
//
//            } else {
//
//                DispatchQueue.main.async {
//                    self.alert.alertMessage(title: "Login Error", message: responseString)
//                    print(responseString)
//                }
//
//            }
//
//        }
        
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
            let userName = self.userNameTextField.text,
            let password = self.passwordTextField.text
        else { return }
        
        // If user name or password field is empty, alert the user with a message and exit the function
        if userName.isEmpty {
            
            alert.alertMessage(title: "Email Required", message: "Email: This field is required.")
            return
            
        } else if password.isEmpty {
            
            alert.alertMessage(title: "Password Required", message: "Password: This field is required.")
            return
            
        }
        
        // Proceed with logging the user in if text fields are not empty
        self.logIn(userName: userName, password: password)
        
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
