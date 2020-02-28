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
    var customer: CustomerModel?
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
    }
    
    // MARK: Set Up
    func setUp() {
        
        // Get current day of the week
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: currentDate)
        
        // Set greeting label text
        if let firstName = customer?.firstName {
            let greetingString = "Hello \(firstName), it's \(weekDay),\nand you have 4 calls."
            self.greetingLabel.text = greetingString
        }
        
        // Set up navigation bar styles
        let backButtonImage: UIImage = UIImage(named: "left-arrow")!
        self.navigationController?.navigationBar.backIndicatorImage = backButtonImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        self.navigationController?.navigationBar.backItem?.title = ""
        
        // Set label greeting label text
        
        
    }

}
