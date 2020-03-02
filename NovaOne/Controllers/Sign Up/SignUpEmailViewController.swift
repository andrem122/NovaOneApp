//
//  SignUpEmailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpEmailViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailAddressTextField: NovaOneTextField!
    
    // MARK: Methods
    func setup() {
        self.emailAddressTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar for next view controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar for this view
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
     // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set text for back button on next view controller
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

}
