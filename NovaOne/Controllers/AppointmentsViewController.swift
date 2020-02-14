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
    
    
    var appointments: [Appointment] = []
    let appointmentInfoOne: [String: Any] = [
        "id": 1,
        "name": "Bob Diller",
        "phoneNumber": "+15613465571",
        "time": "2012-09-23 09:31:22",
        "created": "2012-09-23 09:31:22",
        "timeZone": "America/New_York",
        "confirmed": false,
        "address": "157 Gregory Place",
        "unitType": "3",
        "customerUserId": 3,
    ]
    
    let appointmentInfoTwo: [String: Any] = [
        "id": 2,
        "name": "Gabriel Mashraghi",
        "phoneNumber": "+77213729284",
        "time": "2016-04-10 05:23:89",
        "created": "2012-09-23 09:31:22",
        "timeZone": "America/New_York",
        "confirmed": true,
        "address": "1800 Nebraska Avenue",
        "unitType": "2",
        "customerUserId": 3,
    ]
    
    let appointmentInfoThree: [String: Any] = [
        "id": 3,
        "name": "Richard Yeets",
        "phoneNumber": "+19549372662",
        "time": "2012-09-23 09:31:22",
        "created": "2012-09-23 09:31:22",
        "timeZone": "America/New_York",
        "confirmed": false,
        "address": "1800 Nebraska Avenue",
        "unitType": "1",
        "customerUserId": 3,
    ]
    
    let appointmentsInfo: [[String: Any]] = []
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appointments = self.createAppointmentArray()
        self.appointmentTableView.delegate = self
        self.appointmentTableView.dataSource = self
    }
    
    // Create an array of Appointment objects
    func createAppointmentArray() -> [Appointment] {
        let appointmentsInfo: [[String: Any]] = [self.appointmentInfoOne, self.appointmentInfoTwo, self.appointmentInfoThree]
        
        var tempAppointments: [Appointment]  = []
        
        for appointmentInfo in appointmentsInfo  {
            
            if let id = appointmentInfo["id"] as? Int,
            let name = appointmentInfo["name"] as? String,
            let phoneNumber = appointmentInfo["phoneNumber"] as? String,
            let time = appointmentInfo["time"] as? String,
            let created = appointmentInfo["created"] as? String,
            let timeZone = appointmentInfo["timeZone"] as? String,
            let confirmed = appointmentInfo["confirmed"] as? Bool,
            let address = appointmentInfo["address"] as? String,
            let unitType = appointmentInfo["unitType"] as? String,
            let customerUserId = appointmentInfo["customerUserId"] as? Int {
                
                let appointment: Appointment = Appointment(id: id, name: name, phoneNumber: phoneNumber, time: time, created: created, timeZone: timeZone, confirmed: confirmed, address: address, unitType: unitType, customerUserId: customerUserId)
                
                tempAppointments.append(appointment)
                
            }
            
        }
        
        return tempAppointments
    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTouched(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Enumerations

}

extension AppointmentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appointment: Appointment = appointments[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentTableCell") as! AppointmentTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Pass in appointment object to set up cell properties (address, name, etc.)
        cell.setUpAppointment(appointment: appointment)
        
        return cell
    }
    
    
}
