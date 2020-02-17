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
    var customer: CustomerModel?
    var appointments: [Appointment] = []
    
    let appointmentsInfo: [[String: Any]] = []
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAppointments()
        self.appointmentTableView.delegate = self
        self.appointmentTableView.dataSource = self
    }
    
    // Get's appointments from the database
    func getAppointments() {
        
        let httpRequest = HTTPRequests()
        guard
            let customer = self.customer,
            let customerUserId = customer.id,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else { return }
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/appointments.php",
                            dataModel: Appointment(),
                            parameters: parameters) { (result) in
                                
                                switch result {
                                    case .success(let appointment):
                                        guard let address = appointment.address else { return }
                                        print(address)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                }
                                
        }
        
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
        
        let appointment: Appointment = self.appointments[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentTableCell") as! AppointmentTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Pass in appointment object to set up cell properties (address, name, etc.)
        cell.setUpAppointment(appointment: appointment)
        
        return cell
    }
    
    
}
