//
//  AppointmentsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SkeletonView

class AppointmentsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var appointments: [AppointmentModel] = []
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(self.getAppointments), for: .valueChanged)
        return refreshControl
    }()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupNavigationBar()
        self.setupSkeletonView()
    }
    
    func setupNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    func setupSkeletonView() {
        // Start the animation of the skeleton view
        self.view.showAnimatedGradientSkeleton()
    }
    
    @objc func getAppointments() {
        // Gets appointments from the database via an HTTP request
        // and saves to CoreData
        self.setupSkeletonView()
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            print("Failed to obtain variables for POST request")
            return
        }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/appointments.php",
                            dataModel: [AppointmentModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                let deadline = DispatchTime.now() + .milliseconds(700)
                                switch result {
                                    
                                    case .success(let appointments):
                                        self?.appointments = appointments
                                        
                                        // Stop the refresh control 700 miliseconds after the data is retrieved to make it look more natrual when loading
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.refresher.endRefreshing()
                                            self?.view.hideSkeleton()
                                            self?.appointmentTableView.reloadData() // reload table view so new data shows
                                        }
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.refresher.endRefreshing()
                                            self?.view.hideSkeleton()
                                        }
                                    
                                }
                                
                                
                                
        }
        
    }
    
    func setupTableView() {
        // Set up the table view
        
        self.appointmentTableView.delegate = self
        self.appointmentTableView.dataSource = self
        
        // Refresh control
        if #available(iOS 10.0, *) {
            self.appointmentTableView.refreshControl = self.refresher
        } else {
            self.appointmentTableView.addSubview(self.refresher)
        }
        
        // Set seperator color for table view
        self.appointmentTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
    }

}

extension AppointmentsViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointments.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appointment: AppointmentModel = self.appointments[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        // Pass in appointment object to set up cell properties (address, name, etc.)
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let appointmentTimeDate: Date = appointment.timeDate
        let appointmentTime: String = dateFormatter.string(from: appointmentTimeDate)
        
        let appointmentCreatedDate: Date = appointment.createdDate
        let appointmentCreated: String = dateFormatter.string(from: appointmentCreatedDate)
        
        let title = appointment.name
        let subTitleOne = appointment.address != nil ? appointment.address! : appointmentCreated
        let subTitleTwo = appointment.unitType != nil ? appointment.unitType! : appointment.testType!
        
        cell.setup(title: title, subTitleOne: subTitleOne, subTitleTwo: subTitleTwo, subTitleThree: appointmentTime)
        
        return cell
    }
    
    // Function gets called every time a row in the table gets tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get appointment object based on which row the user taps on
        let appointment = self.appointments[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let appointmentDetailNavigationController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.NavigationControllerIdentifiers.appointmentDetail.rawValue) as? UINavigationController {
            
            guard let appointmentDetailViewController = appointmentDetailNavigationController.viewControllers[0] as? AppointmentDetailViewController else { return }
            appointmentDetailViewController.appointment = appointment
            
            appointmentDetailNavigationController.modalPresentationStyle = .fullScreen
            
            self.present(appointmentDetailNavigationController, animated: true, completion: nil)
            
        }
    }
    
    
}
