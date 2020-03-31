//
//  AppointmentsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentTableView: UITableView!
    var appointments: [AppointmentModel] = []
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    func setupTableView() {
        self.appointmentTableView.delegate = self
        self.appointmentTableView.dataSource = self
        
        // Set seperator color for table view
        self.appointmentTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
    }

}

extension AppointmentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointments.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appointment: AppointmentModel = self.appointments[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cellIdentifier: String = "novaOneTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Pass in appointment object to set up cell properties (address, name, etc.)
        guard
            let name = appointment.name
        else { return cell }
        let address = appointment.shortenedAddress
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let appointmentTimeDate: Date = appointment.timeDate
        let appointmentTime: String = dateFormatter.string(from: appointmentTimeDate)
        
        cell.setup(title: name, subTitleOne: address, subTitleTwo: "2 Bedrooms", subTitleThree: appointmentTime)
        
        return cell
    }
    
    // Function gets called every time a row in the table gets tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get appointment object based on which row the user taps on
        let appointment = self.appointments[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let appointmentDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.appointmentDetail.rawValue) as? AppointmentDetailViewController {
            appointmentDetailViewController.appointment = appointment
            self.present(appointmentDetailViewController, animated: true, completion: nil)
        }
    }
    
    
}
