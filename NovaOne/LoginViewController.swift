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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setUp() {
        
        // Pop up keyboard for username field as soon as view loads
        self.userNameTextField.becomeFirstResponder()
        self.passwordTextField.delegate = self
        
    }
    
    // MARK: Methods
    func logIn(userName: String, password: String) {
        
        let url: String = "https://graystonerealtyfl.com/NovaOne/login.php"
        let httpRequest = HTTPRequests(url: url)
        let parameters: [String: Any] = ["PHPAuthenticationUsername": Defaults().PHPAuthenticationUsername, "PHPAuthenticationPassword": Defaults().PHPAuthenticationPassword, "email": userName, "password": password]
        httpRequest.post(parameters: parameters)
        
        // Go to the userLoggedInStart view
        if let userLoggedInStartViewController = storyboard?.instantiateViewController(identifier: "userLoggedInStart") {
            self.present(userLoggedInStartViewController, animated: true, completion: nil)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Send touch event to the login button so that our data validation logic can be used
        self.loginButton.sendActions(for: .touchUpInside)
        return true
        
    }
    
}
