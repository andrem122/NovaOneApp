//
//  SuccessViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup(title: String, subtitle: String) {
        // Sets up the text for the title and subtitle text
        DispatchQueue.main.async {
            self.titleLabel.text = title
            self.subtitleLabel.text = subtitle
        }
    }
    
    // MARK: Actions
    @IBAction func doneButtonTapped(_ sender: Any) {
        // Navigate to the home screen on the home tab bar controller
        if let homeTabBarViewController = self.storyboard?.instantiateViewController(identifier: Defaults.TabBarControllerIdentifiers.home.rawValue) as? HomeTabBarController {
            
            self.present(homeTabBarViewController, animated: true, completion: nil)
            
        }
    }
    
}
