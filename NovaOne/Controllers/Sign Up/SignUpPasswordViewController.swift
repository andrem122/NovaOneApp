//
//  SignUpPasswordViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpPasswordViewController: BaseSignUpViewController {
    
    // MARK: Properties
    @IBOutlet weak var passwordTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // MARK: Methods
    func setup() {
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
        self.passwordTextField.becomeFirstResponder() // Make text field become first responder
    }
    
    // MARK: Actions
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.passwordTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let password = self.passwordTextField.text else { return }
        if password.count < 10 {
            let popUpOkViewController = self.alertService.popUpOk(title: "Password Length", body: "Password must be at least ten characters long.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let signUpNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpName.rawValue) as? SignUpNameViewController else { return }
            self.customer?.password = password
            signUpNameViewController.customer = self.customer
            self.navigationController?.pushViewController(signUpNameViewController, animated: true)
        }
    }
    
}
