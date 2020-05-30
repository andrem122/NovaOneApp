//
//  CompaniesTableViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/25/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SkeletonView
import CoreData

class CompaniesTableViewController: UITableViewController, NovaOneTableView {
    
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
            let detailViewController = detailNavigationController.viewControllers.first as? CompanyDetailViewController,
            let company = self.filteredObjects.first as? Company
        else { return }
        
        detailViewController.company = company
        detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)

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
        self.objects = PersistenceService.fetchEntity(Company.self, filter: nil, sort: sortDescriptors)
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
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: PersistenceService.context) else { return }
            
            guard let companies = objects as? [CompanyModel] else { return }
            for company in companies {
                if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
                    
                    coreDataCompany.address = company.address
                    coreDataCompany.city = company.city
                    coreDataCompany.created = company.createdDate
                    coreDataCompany.customerUserId = Int32(company.customerUserId)
                    coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
                    coreDataCompany.email = company.email
                    coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
                    coreDataCompany.id = Int32(company.id)
                    coreDataCompany.name = company.name
                    coreDataCompany.phoneNumber = company.phoneNumber
                    coreDataCompany.shortenedAddress = company.shortenedAddress
                    coreDataCompany.state = company.state
                    coreDataCompany.zip = company.zip
                    
                    coreDataCompany.customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
                    
                    // Add appointments
                    if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.appointment.rawValue) > 0 {
                        let predicate = NSPredicate(format: "companyId == %@", String(company.id))
                        let appointments = NSSet(array: PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil))
                        coreDataCompany.addToAppointments(appointments)
                    }
                    
                    // Add leads
                    if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue) > 0 {
                        let predicate = NSPredicate(format: "companyId == %@", String(company.id))
                        let leads = NSSet(array: PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil))
                        coreDataCompany.addToLeads(leads)
                    }
                    
                    
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
                            dataModel: [CompanyModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                let deadline = DispatchTime.now() + .milliseconds(700)
                                switch result {
                                    
                                    case .success(let companies):
                                        // Delete old data if not refreshing table
                                        if append == false {
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.company.rawValue)
                                        }
                                        
                                        // Save new data to CoreData and then set the data array (self.objects) to the new data and reload table
                                        self?.saveObjectsToCoreData(objects: companies)
                                        
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
                                            
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.company.rawValue)
                                            
                                            // Remove table view from container view
                                            guard let companiesContainerViewController = self?.parentViewContainerController as? CompaniesContainerViewController else { return }
                                            companiesContainerViewController.containerView.subviews[0].removeFromSuperview()
                                            
                                            // Show empty state view controller
                                            let containerView = companiesContainerViewController.containerView
                                            let title = "No Companies"
                                            UIHelper.showEmptyStateContainerViewController(for: companiesContainerViewController, containerView: containerView ?? UIView(), title: title) { (emptyViewController) in
                                                emptyViewController.parentViewContainerController = companiesContainerViewController
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
                let lastObject = self.filteredObjects[lastIndex] as? Company
            else { return }
            
            self.getData(endpoint: "/refreshCompanies.php", append: false, lastObjectId: lastObject.id) {
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
                let lastObject = self.filteredObjects.last as? Company
            else { return }
            
            self.getData(endpoint: "/refreshCompanies.php", append: false, lastObjectId: lastObject.id) {
                [weak self] in
                self?.tableIsRefreshing = false
                self?.getCoreData()
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
    }
    
    // MARK: Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let addCompanyNavigationController = self.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addCompany.rawValue) as? UINavigationController else { return }
        addCompanyNavigationController.modalPresentationStyle = .fullScreen
        self.present(addCompanyNavigationController, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Defaults.SegueIdentifiers.companyDetail.rawValue {
            guard
                let indexPath = self.tableView.indexPathForSelectedRow,
                let detailNavigationController = segue.destination as? UINavigationController,
                let detailViewController = detailNavigationController.viewControllers.first as? CompanyDetailViewController,
                let company = self.filteredObjects[indexPath.row] as? Company
            else { return }
            
            detailViewController.company = company
            
            detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            detailViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

}

extension CompaniesTableViewController: UISearchResultsUpdating, SkeletonTableViewDataSource {
    
    // Shows how many rows our table view should show
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        if self.tableIsRefreshing == false {
            // Set up cell with values if we have objects in the objects array
            guard
                let company = self.filteredObjects[indexPath.row] as? Company,
                let title = company.name,
                let city = company.city,
                let state = company.state,
                let zip = company.zip
            else { return cell }
            
            let subTitleOne = "\(city), \(state)"
            
            // Get date of company as a string
            guard let createdTimeDate: Date = company.created else { return cell }
            let createdTime: String = DateHelper.createString(from: createdTimeDate, format: "MMM d, yyyy | h:mm a")
            
            
            cell.setup(title: title, subTitleOne: subTitleOne, subTitleTwo: zip, subTitleThree: createdTime)
            
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
            guard let lastObject = self.filteredObjects[lastItemIndex] as? Company else { return }
            
            // Make HTTP request for more data
            self.getData(endpoint: "/moreCompanies.php", append: true, lastObjectId: lastObject.id) {
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
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let searchText = searchController.searchBar.text,
            let objects = self.objects as? [Company]
        else { return }
        self.filteredObjects = searchText.isEmpty ? self.objects : objects.filter({ (companyObject: Company) -> Bool in
            
            // Companies can be searched via company name and address
            return
                companyObject.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ||
                companyObject.address?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        self.tableView.reloadData()
    }
}
