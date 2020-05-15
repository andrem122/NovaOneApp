//
//  BaseSignUpViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class BaseSignUpViewController: UIViewController {
    
    // MARK: Properties
    let alertService = AlertService()
    var customer: CustomerSignUpModel?
    var company: CompanySignUpModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addKeyboardObservers()
    }
    
    func setupNavigationBar() {
        // Sets up the navigation bar
        // Set styles for navigation bar
        print("Setting up navigation bar...")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = Defaults.novaOneColor
    }

}
