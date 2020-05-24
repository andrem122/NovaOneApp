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

class AppointmentTableViewController: UITableViewController, NovaOneTableView {
    
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
        self.objects = PersistenceService.fetchEntity(Lead.self, filter: nil, sort: sortDescriptors)
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
        // Saves leads data to CoreData
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: PersistenceService.context) else { return }
            
            guard let leads = objects as? [AppointmentModel] else { return }
            for lead in leads {
                if let coreDataAppointment = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Appointment {
                    
                    coreDataLead.id = Int32(lead.id)
                    coreDataLead.name = lead.name
                    coreDataLead.phoneNumber = lead.phoneNumber
                    coreDataLead.email = lead.email
                    coreDataLead.dateOfInquiry = lead.dateOfInquiryDate
                    coreDataLead.renterBrand = lead.renterBrand
                    coreDataLead.companyId = Int32(lead.companyId)
                    coreDataLead.sentTextDate = lead.sentTextDateDate
                    coreDataLead.sentEmailDate = lead.sentEmailDateDate
                    coreDataLead.filledOutForm = lead.filledOutForm
                    coreDataLead.madeAppointment = lead.madeAppointment
                    coreDataLead.companyName = lead.companyName
                    
                    let predicate = NSPredicate(format: "id == %@", String(lead.companyId))
                    coreDataLead.company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
                    
                    
                }
            }
        
            // Save objects to CoreData once they have been inserted into the context container
            PersistenceService.saveContext()
    }
    
    func getData(endpoint: String, append: Bool, firstObjectId: Int32?, lastObjectId: Int32?, completion: (() -> Void)?) {
        <#code#>
    }
    
    func setTimerForTableRefresh() {
        // Setup the timer for automatic refresh of table data
        self.timer = Timer.scheduledTimer(timeInterval: 80.0, target: self, selector: #selector(self.refreshDataAutomatically), userInfo: nil, repeats: true)
    }
    
    // Refresh data
    @objc func refreshDataAutomatically() {
        <#code#>
    }
    
    @objc func refreshDataOnPullDown() {
        <#code#>
    }
    
    // MARK: Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        <#code#>
    }
    

    

}

extension AppointmentTableViewController: UISearchResultsUpdating, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        <#code#>
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        <#code#>
    }
}
