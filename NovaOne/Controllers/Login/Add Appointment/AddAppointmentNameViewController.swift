//
//  AddAppointmentNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentNameViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentNameTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
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
    
    func setupNavigationBar() {
        // Set navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
