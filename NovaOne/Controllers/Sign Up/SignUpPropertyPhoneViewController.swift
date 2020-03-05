//
//  SignUpPropertyPhoneViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpPropertyPhoneViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var propertyPhoneTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.propertyPhoneTextField.becomeFirstResponder()
    }

}
