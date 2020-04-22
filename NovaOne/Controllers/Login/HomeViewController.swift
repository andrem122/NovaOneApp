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
    var homeTabBarController: UITabBarController?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getObjectCounts() {
            [weak self] in
            self?.setupGreetingLabel()
            self?.setupNumberLabels()
        }
    }
    
    func setupGreetingLabel() {
        
        // Get current day of the week
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: currentDate)
        
        // Set greeting label text
        guard let customer = PersistenceService.fetchCustomerEntity() else { return }
        
        guard let firstName = customer.firstName else { return }
        let leadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.leadCount.rawValue)
        let greetingString = "Hello \(firstName), it's \(weekDay),\nand you have \(leadCount) leads."
        self.greetingLabel.text = greetingString
        
    }
    
    func setupNumberLabels() {
        // Setup labels
        
        let leadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.leadCount.rawValue)
        let appointmentCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.appointmentCount.rawValue)
        self.numberOfLeadsLabel.text = String(leadCount)
        self.numberOfAppointmentsLabel.text = String(appointmentCount)
        
        // Add gesture recognizers, so that when the labels are tapped, something happens
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.numberOfLeadsLabelTapped))
        self.numberOfLeadsLabel.isUserInteractionEnabled = true
        self.numberOfLeadsLabel.addGestureRecognizer(tap)
        
    }
    
    func getObjectCounts(success: @escaping () -> Void) {
        // Gets the number of a chosen object from the database
        
        self.showSpinner(for: self.view) // Show the loading screen
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/objectCounts.php", dataModel: [ObjectCount].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let objectCounts):
                    for objectCount in objectCounts {
                        // Save to user defaults for later use
                        UserDefaults.standard.set(objectCount.count, forKey: objectCount.name)
                    }
                    
                    // Run the success completion handler
                    success()
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
            self?.removeSpinner()
            
        }
    }
    
    // MARK: Actions
    @IBAction func numberOfLeadsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }

}
