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
        if let firstName = customer?.firstName {
            let greetingString = "Hello \(firstName)!"
            self.greetingLabel.text = greetingString
        }
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
