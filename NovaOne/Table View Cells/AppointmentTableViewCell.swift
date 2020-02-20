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
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var numberOfBedsLabel: UILabel!
    @IBOutlet weak var numberOfBathsLabel: UILabel!
    @IBOutlet weak var customerIDLabel: UILabel!
    @IBOutlet weak var customerInitialsLabel: UILabel!
    @IBOutlet weak var monthDayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    // Set up the properties above for each cell by passing in an appointment object from
    // cellForRowAt IndexPath function
    func setUpAppointment(appointment: Appointment) {
        
        guard let id = appointment.id else { return }
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yy"
        let appointmentDate: String = dateFormatter.string(from: appointment.timeDate)
        
        // Get time of appointment as a string
        dateFormatter.dateFormat = "h:mm a"
        let appointmentTime: String = dateFormatter.string(from: appointment.timeDate)
        
        self.leftView.addLeftBorderWithColor(color: Defaults().novaOneColor, width: CGFloat(7))
        self.addressLabel.text = appointment.shortenedAddress
        self.customerNameLabel.text = appointment.name
        self.numberOfBedsLabel.text = appointment.unitType
        self.numberOfBathsLabel.text = "2"
        self.customerIDLabel.text = String(id)
        self.customerInitialsLabel.text = appointment.initials
        self.monthDayLabel.text = appointmentDate
        self.timeLabel.text = appointmentTime
        
    }

}
