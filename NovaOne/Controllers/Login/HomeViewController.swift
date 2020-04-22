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
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var numberOfLeadsLabel: UILabel!
    @IBOutlet weak var numberOfAppointmentsLabel: UILabel!
    var leadCount: Int = 0
    var appointmentCount = 0
    var homeTabBarController: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGreetingLabel()
        self.setupNumberLabels()
    }
    
    // MARK: Set Up
    func setupGreetingLabel() {
        
        // Get current day of the week
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: currentDate)
        
        // Set greeting label text
        guard let customer = PersistenceService.fetchCustomerEntity() else { return }
        
        guard let firstName = customer.firstName else { return }
        let greetingString = "Hello \(firstName), it's \(weekDay),\nand you have 4 leads."
        self.greetingLabel.text = greetingString
        
    }
    
    func setupNumberLabels() {
        // Setup labels
        
        self.numberOfLeadsLabel.text = String(self.leadCount)
        
        // Add gesture recognizers, so that when the labels are tapped, something happens
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.numberOfLeadsLabelTapped))
        self.numberOfLeadsLabel.isUserInteractionEnabled = true
        self.numberOfLeadsLabel.addGestureRecognizer(tap)
        
    }
    
    // MARK: Actions
    @IBAction func numberOfLeadsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }
    
    

}
