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
    var customer: CustomerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    func setUp() {
        
        // Pop up keyboard for username field as soon as view loads
        self.userNameTextField.becomeFirstResponder()
        
        // Set delegates for each text field so we can use the delegate methods for each text field
        self.passwordTextField.delegate = self
        self.userNameTextField.delegate = self
        
    }
    
    // MARK: Methods
    func logIn(userName: String, password: String) {
        
        let url: String = "https://graystonerealtyfl.com/NovaOne/login.php"
        let httpRequest = HTTPRequests(url: url)
        let parameters: [String: Any] = ["PHPAuthenticationUsername": Defaults().PHPAuthenticationUsername, "PHPAuthenticationPassword": Defaults().PHPAuthenticationPassword, "email": userName, "password": password]
        httpRequest.post(parameters: parameters) {
            (responseString, data) in
            
            // Go to the userLoggedInStart view if POST request returns a json data object
            // (means login attempt was successful) else pop up an alert with the error message
            // from the PHP script
            if let jsonData = data {
                
                let decoder = JSONDecoder()
                let customer = try! decoder.decode(CustomerModel.self, from: jsonData) // convert json data to customer object
                self.customer = customer
                
                DispatchQueue.main.async {
                    
                    // When you get a view controller by its storyboard ID, it forget that
                    // the view controller is embedded in anything. So swift will forget
                    // that we embedded the home view controller in a navigation controller
                    // The fix for this is below.
                    if let homeViewController = self.storyboard?.instantiateViewController(identifier: "homeView") as? HomeViewController  {
                        
                        let menuNavigationController = UINavigationController(rootViewController: homeViewController)
                        homeViewController.customer = self.customer
                        menuNavigationController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
                        self.present(menuNavigationController, animated: true, completion: nil)
                        
                    }
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.alert.alertMessage(title: "Login Error", message: responseString)
                    print(responseString)
                }
                
            }
            
        }
        
    }
    
    // MARK: Actions
    // On touch of cancel button
    @IBAction func cancelButtonTouch(_ sender: UIButton) {
        
        // Remove the modal popup view on touch of the cancel 'x' button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    // Login button touched
    @IBAction func loginButtonTouch(_ sender: NovaOneButton) {
        
        // Check if fields are empty before proceeding to log in user
        // Input field text
        let userName = self.userNameTextField.text!
        let password = self.passwordTextField.text!
        
        // If user name or password field is empty, alert the user with a message and exit the function
        if userName.isEmpty {
            
            alert.alertMessage(title: "Error", message: "User Name Or Email: This field is required.")
            return
            
        } else if password.isEmpty {
            
            alert.alertMessage(title: "Error", message: "Password: This field is required.")
            return
            
        }
        
        // Proceed with logging the user in if text fields are not empty
        self.logIn(userName: userName, password: password)
        
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
