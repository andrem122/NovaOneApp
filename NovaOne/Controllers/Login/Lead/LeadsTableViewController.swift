//
//  LeadsTableViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData
import SkeletonView

class LeadsTableViewController: UITableViewController, NovaOneTableView {
    
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
    var didSetFirstItem: Bool = false
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshDataOnPullDown), for: .valueChanged)
        return refreshControl
    }()
        
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupSearch()
        self.setupTableView()
        self.removeSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCoreData()
        self.setFirstItemForDetailView()
        self.setTimerForTableRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate() // Invalidate timer when view disapears
    }
    
    func setFirstItemForDetailView() {
        // Show first object details in the detail view controller
        
        DispatchQueue.main.async {
            [weak self] in
            if self?.didSetFirstItem == false {
                print("Showing detail for first item")
                guard
                    let detailNavigationController = self?.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.leadDetail.rawValue) as? UINavigationController,
                    let detailViewController = detailNavigationController.viewControllers.first as? LeadDetailViewController,
                    let lead = self?.filteredObjects.first as? Lead
                else { return }
                
                detailViewController.lead = lead
                detailViewController.navigationItem.leftBarButtonItem = self?.splitViewController?.displayModeButtonItem
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
                
                self?.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
                self?.didSetFirstItem = true // Set to true so it does not run again in viewDidAppear
            }
        }
    }
    
    func setupTableView() {
        // Setup the table view
        // Set seperator color for table view
        self.tableView.separatorStyle = .none
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
    
    func setupNavigationBar() {
        // Setup the navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func getCoreData() {
        // Gets data from CoreData and sorts by id field
        DispatchQueue.main.async { // Run on main thread so we dont grab core data before it is saved into the device
            [weak self] in
            let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            let objects = PersistenceService.fetchEntity(Lead.self, filter: nil, sort: sortDescriptors)
            self?.objects = objects
            self?.filteredObjects = objects
            self?.tableView.reloadData()
        }
    }
    
    func hideTableLoadingAnimations() {
        // Stop all animations that occur when the table is loading data and reload table data
        self.refresher.endRefreshing()
        self.bottomTableViewSpinner?.stopAnimating()
        self.view.hideSkeleton()
    }
    
    func setTimerForTableRefresh() {
        // Setup the timer for automatic refresh of table data
        self.timer = Timer.scheduledTimer(timeInterval: 80.0, target: self, selector: #selector(self.refreshDataAutomatically), userInfo: nil, repeats: true)
    }
    
    func saveObjectsToCoreData(objects: [Decodable]) {
        // Saves leads data to CoreData
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.lead.rawValue, in: PersistenceService.context) else { return }
            
            guard let leads = objects as? [LeadModel] else { return }
            for lead in leads {
                if let coreDataLead = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Lead {
                    
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
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint,
                            dataModel: [LeadModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                let deadline = DispatchTime.now() + .milliseconds(700)
                                switch result {
                                    
                                    case .success(let leads):
                                        // Delete old data if not refreshing table
                                        if append == false {
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.lead.rawValue)
                                        }
                                        
                                        // Save new data to CoreData and then set the data array (self.leads) to the new data and reload table
                                        self?.saveObjectsToCoreData(objects: leads)
                                        
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
                                        // leads from core data. This means the user could have added a lead online through the
                                        // website and deleted online. Our app needs to delete all data to reflect the changes
                                        // made online.
                                        if self?.appendingDataToTable == false && error.localizedDescription == Defaults.ErrorResponseReasons.noData.rawValue {
                                            
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.lead.rawValue)
                                            
                                            guard let leadsContainerViewController = self?.parentViewContainerController as? LeadsContainerViewController else { return }
                                            leadsContainerViewController.containerView.subviews[0].removeFromSuperview()
                                            
                                            // Show empty state view controller
                                            let containerView = leadsContainerViewController.containerView
                                            let title = "No Leads"
                                            UIHelper.showEmptyStateContainerViewController(for: leadsContainerViewController, containerView: containerView ?? UIView(), title: title, addObjectButtonTitle: "Add Lead") { (emptyViewController) in
                                                
                                                emptyViewController.parentViewContainerController = leadsContainerViewController
                                                
                                                // Pass the addObjectHandler function and button title to the empty view controller
                                                emptyViewController.addObjectButtonHandler = {
                                                    [weak self] in
                                                    // Go to the add object screen
                                                    guard let addLeadNavigationController = self?.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addLead.rawValue) as? UINavigationController else { return }
                                                    self?.present(addLeadNavigationController, animated: true, completion: nil)
                                                }
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
    
    @objc func refreshDataAutomatically() {
        // Refresh data of the table view if the user is not scrolling
        
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && self.filteredObjects.count > 0 && self.tableView.isDecelerating == false && self.tableView.isDragging == false && self.searchController.isActive == false {
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.filteredObjects.count - 1
            guard
                let lastObject = self.filteredObjects[lastIndex] as? Lead
            else { return }
            
            self.getData(endpoint: "/refreshLeads.php", append: false, lastObjectId: lastObject.id) {
                [weak self] in
                self?.tableIsRefreshing = false
                self?.getCoreData()
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
                let lastObject = self.filteredObjects.last as? Lead
            else { return }
            
            self.getData(endpoint: "/refreshLeads.php", append: false, lastObjectId: lastObject.id) {
                [weak self] in
                self?.tableIsRefreshing = false
                self?.getCoreData()
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Defaults.SegueIdentifiers.leadDetail.rawValue {
            
            guard
                let detailNavigationController = segue.destination as? UINavigationController,
                let detailViewController = detailNavigationController.viewControllers.first as? LeadDetailViewController,
                let indexPath = self.tableView.indexPathForSelectedRow,
                let lead = self.filteredObjects[indexPath.row] as? Lead
            else { return }
            
            detailViewController.lead = lead
            
            detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            detailViewController.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }
    
    // MARK: Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let addLeadNavigationController = self.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addLead.rawValue) as? UINavigationController else { return }
        self.present(addLeadNavigationController, animated: true, completion: nil)
    }
}

extension LeadsTableViewController: UISearchResultsUpdating, SkeletonTableViewDataSource {
    
    // Shows how many rows our table view should show
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        if self.tableIsRefreshing == false {
            // Set up cell with values if we have objects in the leads array
            guard let lead = self.filteredObjects[indexPath.row] as? Lead else { return cell } // Get the object based on the row number each cell is in
            guard
                let name = lead.name,
                let companyName = lead.companyName,
                let leadBrand = lead.renterBrand,
                let dateOfInquiry = lead.dateOfInquiry
            else { return cell }
            
            // Get date of lead as a string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
            let dateContacted: String = dateFormatter.string(from: dateOfInquiry)
            
            cell.setup(title: name, subTitleOne: companyName, subTitleTwo: leadBrand, subTitleThree: dateContacted)
            
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
            guard let lastObject = self.filteredObjects[lastItemIndex] as? Lead else { return }
            
            // Make HTTP request for more data
            self.getData(endpoint: "/moreLeads.php", append: true, lastObjectId: lastObject.id) {
                [weak self] in
                self?.appendingDataToTable = false
                self?.getCoreData()
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
    
        func updateSearchResults(for searchController: UISearchController) {
        guard
            let searchText = searchController.searchBar.text,
            let objects = self.objects as? [Lead]
        else { return }
        self.filteredObjects = searchText.isEmpty ? self.objects : objects.filter({ (leadObject: Lead) -> Bool in
            
            // Leads can be serached via name, company name, and renter brand
            return
                leadObject.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ||
                leadObject.companyName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ||
                leadObject.renterBrand?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        self.tableView.reloadData()
    }
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
}
