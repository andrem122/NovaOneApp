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
    var bottomTableViewSpinner: UIActivityIndicatorView? = nil
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
        self.setupSkeletonView()
    }
    
    func setupNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    func setupSkeletonView() {
        self.view.showAnimatedGradientSkeleton()
    }
    
    func getData(endpoint: String, append: Bool, lastObjectId: Int?) {
        // Gets appointments from the database via an HTTP request
        // and saves to CoreData
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            print("Failed to obtain variables for POST request")
            self.refresher.endRefreshing()
            return
        }
        let customerUserId = customer.id
        let unwrappedLastObjectId = lastObjectId != nil ? lastObjectId! : 0

        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any,
                                         "lastObjectId": unwrappedLastObjectId as Any]
        
        httpRequest.request(endpoint: endpoint,
                            dataModel: [AppointmentModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                let deadline = DispatchTime.now() + .milliseconds(700)
                                switch result {
                                    
                                    case .success(let appointments):
                                        
                                        // Append to the appointments array or make overwrite
                                        if append {
                                            self?.appointments.append(contentsOf: appointments)
                                        } else {
                                            self?.appointments = appointments
                                        }
                                        
                                        // Stop the refresh control 700 miliseconds after the data is retrieved to make it look more natrual when loading
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.refresher.endRefreshing()
                                            self?.bottomTableViewSpinner?.stopAnimating()
                                            self?.view.hideSkeleton()
                                            self?.appointmentTableView.reloadData()
                                        }
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.view.hideSkeleton()
                                            self?.bottomTableViewSpinner?.stopAnimating()
                                            self?.refresher.endRefreshing()
                                        }
                                    
                                }
                                
        }
    }
    
    @objc func refreshData() {
        // Refresh data on pull down of the table view
        self.setupSkeletonView()
        self.getData(endpoint: "/appointments.php", append: false, lastObjectId: nil)
    }
    
    func setupTableView() {
        // Set seperator color for table view
        self.appointmentTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.appointmentTableView.delegate = self
        self.appointmentTableView.dataSource = self
        
        // Refresh control
        if #available(iOS 10.0, *) {
            self.appointmentTableView.refreshControl = self.refresher
        } else {
            self.appointmentTableView.addSubview(self.refresher)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get appointment object based on which row the user taps on
        let appointment = self.appointments[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let appointmentDetailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.appointmentDetail.rawValue) as? AppointmentDetailViewController {
            
            appointmentDetailViewController.appointment = appointment
            appointmentDetailViewController.modalPresentationStyle = .automatic
            self.present(appointmentDetailViewController, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Get last item index from data array
        let lastItemIndex = self.appointments.count - 1
        
        if self.appointments.count > 0 && indexPath.row == lastItemIndex {
            let lastObjectId = self.appointments[lastItemIndex].id
            // Get more data
            self.loadMoreDataOnEndScroll(lastObjectId: lastObjectId)
        }
        
        // Show loading indicator at bottom of table view
        let lastSectionIndex = tableView.numberOfSections - 1 // Get last section in tableview
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1 // Get last row index in last section of tableview
        
        // If at the last row in the last section of the table
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            self.bottomTableViewSpinner = UIActivityIndicatorView(style: .medium)
            self.bottomTableViewSpinner?.startAnimating()
            self.bottomTableViewSpinner?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
            
            self.appointmentTableView.tableFooterView = self.bottomTableViewSpinner
            self.appointmentTableView.tableFooterView?.isHidden = false
        }
        

    }
    
    func loadMoreDataOnEndScroll(lastObjectId: Int) {
        // Gets more appointments from the database after scrolling past
        // the last appointment in the table
        print("Getting more appointments from the database")
        self.getData(endpoint: "/moreAppointments.php", append: true, lastObjectId: lastObjectId)
        
    }
}
