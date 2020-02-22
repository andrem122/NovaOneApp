//
//  AppointmentTableViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var appointmentTimeLabel: UILabel!
    @IBOutlet weak var rightBorderView: UIView!
    
    // Set up the properties above for each cell by passing in an appointment object from
    // cellForRowAt IndexPath function
    func setUpAppointment(appointment: Appointment) {
        
        guard let name = appointment.name else { return }
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let appointmentDate: String = dateFormatter.string(from: appointment.timeDate)
        
        // Get time of appointment as a string
        dateFormatter.dateFormat = "h:mm a"
        let appointmentTime: String = dateFormatter.string(from: appointment.timeDate)
        
        let timeString: String = "\(appointmentDate) | \(appointmentTime)"
        
        // Set cell property values
        self.nameLabel.text = name
        self.appointmentTimeLabel.text = timeString
        self.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.rightBorderView.addBorders(edges: [.right], color: UIColor(white: 0.95, alpha: 1), width: 2)
        
    }

}
