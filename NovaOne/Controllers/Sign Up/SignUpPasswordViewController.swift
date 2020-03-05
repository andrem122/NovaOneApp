//
//  SignUpPasswordViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpPasswordViewController: UIViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.passwordTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.passwordTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set text for back button on next view controller
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }

}
