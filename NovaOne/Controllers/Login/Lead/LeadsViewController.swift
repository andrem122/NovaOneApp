//
//  LeadsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SkeletonView
import CoreData

class LeadsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var leadsTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var timer: Timer?
    var parentViewContainerController: UIViewController?
    var customer: CustomerModel?
    var bottomTableViewSpinner: UIActivityIndicatorView? = nil
    var tableIsRefreshing: Bool = false
    var appendingDataToTable: Bool = false
    var leads: [Lead] = []
    var filteredLeads: [Lead] = []
    var searchController: UISearchController!
    let alertService = AlertService()
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
    
    func setupSearch() {
        // Setup the search bar and other things needed for the search bar to work
        
        self.filteredLeads = self.leads
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        self.searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.obscuresBackgroundDuringPresentation = false
        
        // Set the header of the table view to the search bar
        self.leadsTableView.tableHeaderView = self.searchController.searchBar
        
        // Sets this view controller as presenting view controller for the search interface
        self.definesPresentationContext = true
    }
    
    func setupNavigationBar() {
        // Setup the navigation bar
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    func getCoreData() {
        // Gets data from CoreData and sorts by dateOfInquiry field
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        self.leads = PersistenceService.fetchEntity(Lead.self, filter: nil, sort: sortDescriptors)
        self.filteredLeads = self.leads
    }
    
    func hideTableLoadingAnimations() {
        // Stop all animations that occur when the table is loading data and reload table data
        self.refresher.endRefreshing()
        self.bottomTableViewSpinner?.stopAnimating()
        self.view.hideSkeleton()
        self.leadsTableView.reloadData()
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
                    
                    let predicate = NSPredicate(format: "id == %@", String(lead.companyId))
                    coreDataLead.company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
                    
                    
                }
            }
        
            // Save objects to CoreData once they have been inserted into the context container
            PersistenceService.saveContext()
    }
    
    func getData(endpoint: String, append: Bool, firstObjectId: Int32?, lastObjectId: Int32?, completion: (() -> Void)?) {
        // Get data from the database via an HTTP request
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            self.refresher.endRefreshing()
            return
        }
        let customerUserId = customer.id
        let unwrappedFirstObjectId = firstObjectId != nil ? firstObjectId! : 0
        let unwrappedLastObjectId = lastObjectId != nil ? lastObjectId! : 0

        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any,
                                         "firstObjectId": unwrappedFirstObjectId as Any,
                                         "lastObjectId": unwrappedLastObjectId as Any]
        
        httpRequest.request(endpoint: endpoint,
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
                                        
                                        if error.localizedDescription != Defaults.ErrorResponseReasons.noRowsFound.rawValue {
                                            let title = "Error"
                                            let body = error.localizedDescription
                                            guard let popUpOkViewController = self?.alertService.popUpOk(title: title, body: body) else { return }
                                            self?.present(popUpOkViewController, animated: true, completion: nil)
                                        }
                                        
                                        
                                        // If no rows were found, delete all
                                        // leads from core data. This means the user could have added a lead online through the
                                        // website and deleted online. Our app needs to delete all data to reflect the changes
                                        // made online.
                                        if self?.appendingDataToTable == false && error.localizedDescription == Defaults.ErrorResponseReasons.noRowsFound.rawValue {
                                            
                                            PersistenceService.deleteAllData(for: Defaults.CoreDataEntities.lead.rawValue)
                                            
                                            guard let leadsContainerViewController = self?.parentViewContainerController as? LeadsContainerViewController else { return }
                                            leadsContainerViewController.containerView.subviews[0].removeFromSuperview()
                                            
                                            // Show empty state view controller
                                            let containerView = leadsContainerViewController.containerView
                                            let title = "No Leads"
                                            UIHelper.showEmptyStateContainerViewController(for: leadsContainerViewController, containerView: containerView ?? UIView(), title: title) { (emptyViewController) in
                                                emptyViewController.parentViewContainerController = leadsContainerViewController
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
        
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && filteredLeads.count > 0 && self.leadsTableView.isDecelerating == false && self.leadsTableView.isDragging == false && self.searchController.isActive == false {
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.filteredLeads.count - 1
            let firstObjectId = self.filteredLeads[0].id
            let lastObjectId = self.filteredLeads[lastIndex].id
            
            self.getData(endpoint: "/refreshLeads.php", append: false, firstObjectId: firstObjectId, lastObjectId: lastObjectId) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
        
    }
    
    @objc func refreshDataOnPullDown() {
        // Refresh data of the table view if the user is not scrolling
        
        if self.searchController.isActive == false && self.appendingDataToTable == false && self.tableIsRefreshing == false && self.filteredLeads.count > 0 {
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.filteredLeads.count - 1
            let firstObjectId = self.filteredLeads[0].id
            let lastObjectId = self.filteredLeads[lastIndex].id
            
            self.getData(endpoint: "/refreshLeads.php", append: false, firstObjectId: firstObjectId, lastObjectId: lastObjectId) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
        } else {
            self.hideTableLoadingAnimations()
        }
        
    }
    
    func setupTableView() {
        // Set seperator color for table view
        self.leadsTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.leadsTableView.delegate = self
        self.leadsTableView.dataSource = self
        
        // Refresh control
        if #available(iOS 10.0, *) {
            self.leadsTableView.refreshControl = self.refresher
        } else {
            self.leadsTableView.addSubview(self.refresher)
        }
    }

}

extension LeadsViewController: UITableViewDelegate, UISearchResultsUpdating, SkeletonTableViewDataSource {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        self.filteredLeads = searchText.isEmpty ? self.leads : self.leads.filter({ (leadObject: Lead) -> Bool in
            
            // Leads can be serached via name, company name, and renter brand
            return
                leadObject.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ||
                leadObject.companyName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ||
                leadObject.renterBrand?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        self.leadsTableView.reloadData()
    }
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLeads.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        if self.tableIsRefreshing == false {
            // Set up cell with values if we have objects in the leads array
            let lead: Lead = self.filteredLeads[indexPath.row] // Get the object based on the row number each cell is in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get lead object based on which row the user taps on
        let lead = self.filteredLeads[indexPath.row]
        
        //Get detail view controller, pass object to it, and present it
        if let leadDetailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.leadDetail.rawValue) as? LeadDetailViewController {
            
            leadDetailViewController.lead = lead
            leadDetailViewController.modalPresentationStyle = .automatic
            self.present(leadDetailViewController, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Show loading indicator at bottom of table view
        let lastSectionIndex = tableView.numberOfSections - 1 // Get last section in tableview
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1 // Get last row index in last section of tableview
        
        // If at the last row in the last section of the table
        if self.searchController.isActive == false && self.appendingDataToTable == false && self.tableIsRefreshing == false && tableView.isDragging && indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            
            self.appendingDataToTable = true
            let lastItemIndex = self.filteredLeads.count - 1
            let lastObjectId = self.filteredLeads[lastItemIndex].id
            
            // Make HTTP request for more data
            self.getData(endpoint: "/moreLeads.php", append: true, firstObjectId: nil, lastObjectId: lastObjectId) {
                [weak self] in
                self?.appendingDataToTable = false
            }
            
            // Make loading icon
            self.bottomTableViewSpinner = UIActivityIndicatorView(style: .medium)
            self.bottomTableViewSpinner?.startAnimating()
            self.bottomTableViewSpinner?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
            
            // Show the loading icon on the table footer
            self.leadsTableView.tableFooterView = self.bottomTableViewSpinner
            self.leadsTableView.tableFooterView?.isHidden = false
        }
        

    }
    
}
