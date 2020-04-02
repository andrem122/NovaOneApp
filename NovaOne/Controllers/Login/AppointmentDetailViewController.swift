//
//  NovaOneDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/6/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailCells: [[String : String]] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    var appointment: AppointmentModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObjectDetailCellsAndTitle()
        self.setupTableView()
    }
    
    func setupTableView() {
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
    }
    
    func convert(appointment date: Date) -> String {
        // Convert date object to a string in a date format
        
        // Get dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let formattedDate: String = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Set cells up for the table view
        
        guard
            let appointment = self.appointment,
            let name = appointment.name,
            let confirmed = appointment.confirmed
        else { return }
        
        let appointmentTime: String = self.convert(appointment: appointment.timeDate)
        let appointmentCreated: String = self.convert(appointment: appointment.createdDate)
        let confirmedString = confirmed ? "Yes" : "No"
        let address = appointment.shortenedAddress
        
        // Create dictionaries for cells
        let nameCell = ["cellTitle": "Name", "cellTitleValue": name]
        let addressCell = ["cellTitle": "Address", "cellTitleValue": address]
        let appointmentTimeCell = ["cellTitle": "Time", "cellTitleValue": appointmentTime]
        let appointmentCreatedCell = ["cellTitle": "Created", "cellTitleValue": appointmentCreated]
        let appointmentConfirmedCell = ["cellTitle": "Confirmed", "cellTitleValue": confirmedString]
        
        self.titleLabel.text = name
        self.objectDetailCells = [
            nameCell,
            addressCell,
            appointmentTimeCell,
            appointmentCreatedCell,
            appointmentConfirmedCell]
    }

}

extension AppointmentDetailViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailCell = self.objectDetailCells[indexPath.row]
        
        cell.setup(cellTitle: objectDetailCell["cellTitle"]!, cellTitleValue: objectDetailCell["cellTitleValue"]!)
        
        return cell
    }
}
