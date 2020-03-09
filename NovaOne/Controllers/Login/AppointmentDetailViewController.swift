//
//  NovaOneDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/6/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var appointmentTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var unitTypeLabel: UILabel!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    var appointment: Appointment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        // Set up values for labels from appointment object
        if let appointment = self.appointment {
            
            // Get data from appointment object
            let appointmentTimeDate = appointment.timeDate
            let appointmentCreatedDate = appointment.createdDate
            
            // Get dates as strings
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            let appointmentTime: String = dateFormatter.string(from: appointmentTimeDate)
            let appointmentCreated: String = dateFormatter.string(from: appointmentCreatedDate)
            
            
            guard
                let name = appointment.name,
                let unitType = appointment.unitType,
                let confirmed = appointment.confirmed
            else { return }
            
            let confirmedString = confirmed ? "Yes" : "No"
            
            // Set values for labels
            self.nameLabel.text = name
            self.appointmentTimeLabel.text = appointmentTime
            self.addressLabel.text = appointment.shortenedAddress
            self.unitTypeLabel.text = unitType
            self.createdLabel.text = appointmentCreated
            self.confirmedLabel.text = confirmedString
        }
    }

}
