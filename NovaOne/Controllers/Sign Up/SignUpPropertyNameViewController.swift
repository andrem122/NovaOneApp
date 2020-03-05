//
//  SignUpPropertyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpPropertyNameViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var propertyNameTextField: NovaOneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.propertyNameTextField.becomeFirstResponder()
    }

}
