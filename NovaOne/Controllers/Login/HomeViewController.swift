//
//  UserLoggedInStartViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    // MARK: Properties
    var customer: Customer?
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCoreData()
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
        guard let customer = self.customer else {
            print("Customer object is nil!")
            return
        }
        if let firstName = customer.firstName {
            let greetingString = "Hello \(firstName), it's \(weekDay),\nand you have 4 calls."
            self.greetingLabel.text = greetingString
            print(greetingString)
        } else {
            print("First Name is nil!")
        }
        
    }
    
    func fetchCoreData() {
        // Get the data saved in CoreData
        // Fetch customer data stored in CoreData
        let customers = PersistenceService.fetchEntities(entity: Customer())
        
        for customer in customers {
            print(customer.firstName as Any)
        }
    }

}
