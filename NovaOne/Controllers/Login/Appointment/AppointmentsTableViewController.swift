//
//  AppointmentTableViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData
import SkeletonView

class AppointmentsTableViewController: UITableViewController, NovaOneTableView {
    
    // MARK: Properties
    var timer: Timer?
    var parentViewContainerController: UIViewController?
    var customer: CustomerModel?
    var bottomTableViewSpinner: UIActivityIndicatorView? = nil
    var tableIsRefreshing: Bool = false
    var appendingDataToTable: Bool = false
    var objects: [NSManagedObject] = []
    var filteredObjects: [NSManagedObject] = []
    var searchController: UISearchController!
    var alertService = AlertService()
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshDataOnPullDown), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCoreData()
        self.setupNavigationBar()
        self.setupSearch()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTimerForTableRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate() // Invalidate timer when view disapears
    }
    
    func setupTableView() {
        // Setup the table view
        
        // Show first object details in the detail view controller
        guard
            let detailNavigationController = self.splitViewController?.viewControllers.last as? UINavigationController,
            let detailViewController = detailNavigationController.viewControllers.first as? AppointmentDetailViewController,
            let appointment = self.filteredObjects.first as? Appointment
        else { return }
        
        detailViewController.appointment = appointment
        detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)

        // Set seperator color for table view
        self.tableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.clearsSelectionOnViewWillAppear = false
        
        // Refresh control
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.refresher
        } else {
            self.tableView.addSubview(self.refresher)
        }
    }
    
    func setupNavigationBar() {
        // Setup the navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupSearch() {
        // Setup the search bar and other things needed for the search bar to work
               
       self.filteredObjects = self.objects
       
       // Initializing with searchResultsController set to nil means that
       // searchController will use this view controller to display the search results
       self.searchController = UISearchController(searchResultsController: nil)
       searchController.searchResultsUpdater = self
       self.searchController.searchBar.sizeToFit()
       self.searchController.obscuresBackgroundDuringPresentation = false
       
       // Set the header of the table view to the search bar
       self.tableView.tableHeaderView = self.searchController.searchBar
       
       // Sets this view controller as presenting view controller for the search interface
       self.definesPresentationContext = true
    }
    
    func getCoreData() {
        // Gets data from CoreData and sorts by dateOfInquiry field
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        self.objects = PersistenceService.fetchEntity(Appointment.self, filter: nil, sort: sortDescriptors)
        self.filteredObjects = self.objects
    }
    
    func hideTableLoadingAnimations() {
        // Stop all animations that occur when the table is loading data and reload table data
        self.refresher.endRefreshing()
        self.bottomTableViewSpinner?.stopAnimating()
        self.view.hideSkeleton()
        self.tableView.reloadData()
    }
    
    func saveObjectsToCoreData(objects: [Decodable]) {
        // Saves objects data to CoreData
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.appointment.rawValue, in: PersistenceService.context) else { return }
            
            guard let appointments = objects as? [AppointmentModel] else { return }
            for appointment in appointments {
                if let coreDataAppointment = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Appointment {
                    
                    coreDataAppointment.address = appointment.address
                    coreDataAppointment.companyId = Int32(appointment.companyId)
                    coreDataAppointment.confirmed = appointment.confirmed
                    coreDataAppointment.created = appointment.createdDate
                    coreDataAppointment.dateOfBirth = appointment.dateOfBirthDate
                    coreDataAppointment.email = appointment.email
                    coreDataAppointment.gender = appointment.gender
                    coreDataAppointment.id = Int32(appointment.id)
                    coreDataAppointment.name = appointment.name
                    coreDataAppointment.phoneNumber = appointment.phoneNumber
                    coreDataAppointment.testType = appointment.testType
                    coreDataAppointment.time = appointment.timeDate
                    coreDataAppointment.timeZone = appointment.timeZone
                    coreDataAppointment.unitType = appointment.unitType
                    
                    let predicate = NSPredicate(format: "id == %@", String(appointment.companyId))
                    coreDataAppointment.company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
                    
                    
                }
            }
        
            // Save objects to CoreData once they have been inserted into the context container
            PersistenceService.saveContext()
    }
    
    func getData(endpoint: String, append: Bool, lastObjectId: Int32?, completion: (() -> Void)?) {
        // Get data from the database via an HTTP request
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
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
                                        // Delete old data if not refreshing table
                                        if append == false {
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.appointment.rawValue)
                                        }
                                        
                                        // Save new data to CoreData and then set the data array (self.objects) to the new data and reload table
                                        self?.saveObjectsToCoreData(objects: appointments)
                                        self?.getCoreData()
                                        
                                        // Stop the refresh control 700 miliseconds after the data is retrieved to make it look more natrual when loading
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.hideTableLoadingAnimations()
                                            // Run the completion handler
                                            guard let unwrappedCompletion = completion else { return }
                                            unwrappedCompletion()
                                        }
                                    
                                    case .failure(let error):
                                        // If there is an error other than 'No rows found', display the error in a
                                        // pop up OK view controller
                                        
                                        if error.localizedDescription != Defaults.ErrorResponseReasons.noData.rawValue {
                                            let title = "Error"
                                            let body = error.localizedDescription
                                            guard let popUpOkViewController = self?.alertService.popUpOk(title: title, body: body) else { return }
                                            self?.present(popUpOkViewController, animated: true, completion: nil)
                                        }
                                        
                                        
                                        // If no rows were found, delete all
                                        // objects from core data. This means the user could have added a object online through the
                                        // website and deleted online. Our app needs to delete all data to reflect the changes
                                        // made online.
                                        if self?.appendingDataToTable == false && error.localizedDescription == Defaults.ErrorResponseReasons.noData.rawValue {
                                            
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.appointment.rawValue)
                                            
                                            // Remove table view from container view
                                            guard let appointmentsContainerViewController = self?.parentViewContainerController as? AppointmentsContainerViewController else { return }
                                            appointmentsContainerViewController.containerView.subviews[0].removeFromSuperview()
                                            
                                            // Show empty state view controller
                                            let containerView = appointmentsContainerViewController.containerView
                                            let title = "No Appointments"
                                            UIHelper.showEmptyStateContainerViewController(for: appointmentsContainerViewController, containerView: containerView ?? UIView(), title: title) { (emptyViewController) in
                                                emptyViewController.parentViewContainerController = appointmentsContainerViewController
                                            }
                                            
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.hideTableLoadingAnimations()
                                            // Run the completion handler
                                            guard let unwrappedCompletion = completion else { return }
                                            unwrappedCompletion()
                                        }
                                    
                                }
                                
        }
    }
    
    func setTimerForTableRefresh() {
        // Setup the timer for automatic refresh of table data
        self.timer = Timer.scheduledTimer(timeInterval: 80.0, target: self, selector: #selector(self.refreshDataAutomatically), userInfo: nil, repeats: true)
    }
    
    // Refresh data
    @objc func refreshDataAutomatically() {
        // Refresh data of the table view if the user is not scrolling
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && self.filteredObjects.count > 0 && self.tableView.isDecelerating == false && self.tableView.isDragging == false && self.searchController.isActive == false {
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.filteredObjects.count - 1
            guard
                let lastObject = self.filteredObjects[lastIndex] as? Appointment
            else { return }
            
            self.getData(endpoint: "/refreshAppointments.php", append: false, lastObjectId: lastObject.id) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
    }
    
    @objc func refreshDataOnPullDown() {
        // Refresh data of the table view if the user is not scrolling
        
        if self.searchController.isActive == false && self.appendingDataToTable == false && self.tableIsRefreshing == false && self.filteredObjects.count > 0 {
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            guard
                let lastObject = self.filteredObjects.last as? Appointment
            else { return }
            
            self.getData(endpoint: "/refreshAppointments.php", append: false, lastObjectId: lastObject.id) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
    }
    
    // MARK: Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let addAppointmentNavigationController = self.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addAppointment.rawValue) as? UINavigationController else { return }
        self.present(addAppointmentNavigationController, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Defaults.SegueIdentifiers.appointmentDetail.rawValue {
            guard
                let indexPath = self.tableView.indexPathForSelectedRow,
                let appointmentDetailNavigationController = segue.destination as? UINavigationController,
                let appointmentDetailViewController = appointmentDetailNavigationController.viewControllers.first as? AppointmentDetailViewController,
                let appointment = self.filteredObjects[indexPath.row] as? Appointment
            else { return }
            
            appointmentDetailViewController.appointment = appointment
            
            appointmentDetailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            appointmentDetailViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

}

extension AppointmentsTableViewController: UISearchResultsUpdating, SkeletonTableViewDataSource {
    
    // Shows how many rows our table view should show
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        if self.tableIsRefreshing == false {
            // Set up cell with values if we have objects in the objects array
            guard let appointment = self.filteredObjects[indexPath.row] as? Appointment else { return cell } // Get the object based on the row number each cell is in
            
            // Get data from object for cell display
            guard let appointmentTimeDate: Date = appointment.time else { return cell }
            let format = "MMM d, yyyy | h:mm a"
            let appointmentTime: String = DateHelper.createString(from: appointmentTimeDate, format: format)
            
            guard let appointmentCreatedDate: Date = appointment.created else { return cell }
            let appointmentCreated: String = DateHelper.createString(from: appointmentCreatedDate, format: format)
            
            guard let title = appointment.name else { return cell }
            let subTitleOne = appointment.address != nil ? appointment.address! : appointmentCreated
            let subTitleTwo = appointment.unitType != nil ? appointment.unitType! : appointment.testType!
            
            cell.setup(title: title, subTitleOne: subTitleOne, subTitleTwo: subTitleTwo, subTitleThree: appointmentTime)
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Show loading indicator at bottom of table view
        let lastSectionIndex = tableView.numberOfSections - 1 // Get last section in tableview
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1 // Get last row index in last section of tableview
        
        // If at the last row in the last section of the table
        if self.searchController.isActive == false && self.appendingDataToTable == false && self.tableIsRefreshing == false && tableView.isDragging && indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            
            self.appendingDataToTable = true
            let lastItemIndex = self.filteredObjects.count - 1
            guard let lastObject = self.filteredObjects[lastItemIndex] as? Appointment else { return }
            
            // Make HTTP request for more data
            self.getData(endpoint: "/moreAppointments.php", append: true, lastObjectId: lastObject.id) {
                [weak self] in
                self?.appendingDataToTable = false
            }
            
            // Make loading icon
            self.bottomTableViewSpinner = UIActivityIndicatorView(style: .medium)
            self.bottomTableViewSpinner?.startAnimating()
            self.bottomTableViewSpinner?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
            
            // Show the loading icon on the table footer
            self.tableView.tableFooterView = self.bottomTableViewSpinner
            self.tableView.tableFooterView?.isHidden = false
        }
        

    }
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let searchText = searchController.searchBar.text,
            let objects = self.objects as? [Appointment]
        else { return }
        self.filteredObjects = searchText.isEmpty ? self.objects : objects.filter({ (appointmentObject: Appointment) -> Bool in
            
            // Appointments can be serached via name, company name, and test type
            return
                appointmentObject.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        self.tableView.reloadData()
    }
}
