//
//  UserLoggedInStartViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var greetingLabel: UILabel!
    var customer: CustomerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    // MARK: Set Up
    func setUp() {
        
        // Set greeting label text
        if let firstName = customer?.firstName {
            let greetingString = "Hello \(firstName)!"
            self.greetingLabel.text = greetingString
        }
        
        // Set up navigation bar styles
        let backButtonImage: UIImage = UIImage(named: "left-arrow")!
        self.navigationController?.navigationBar.backIndicatorImage = backButtonImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    // MARK: Actions
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController: UIViewController = segue.destination
        
        if let appointmentsViewController = viewController as? AppointmentsViewController {
            appointmentsViewController.customer = self.customer
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
