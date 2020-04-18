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
    var customer: CustomerModel?
    var bottomTableViewSpinner: UIActivityIndicatorView? = nil
    var tableIsRefreshing: Bool = false
    var appendingDataToTable: Bool = false
    var leads: [Lead] = []
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
    
    func setupNavigationBar() {
        // Setup the navigation bar
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    func getCoreData() {
        // Gets data from CoreData and sorts by dateOfInquiry field
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        self.leads = PersistenceService.fetchEntity(Lead.self, with: nil, sort: sortDescriptors)
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
        print("Timer object created")
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
                    coreDataLead.company = PersistenceService.fetchEntity(Company.self, with: predicate, sort: nil).first
                    
                    
                }
            }
        
            // Save objects to CoreData once they have been inserted into the context container
            PersistenceService.saveContext()
    }
    
    func getData(endpoint: String, append: Bool, lastObjectId: Int32?, completion: (() -> Void)?) {
        // Get data from the database via an HTTP request
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, with: nil, sort: nil).first,
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
                                        print(error.localizedDescription)
                                        
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
        
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && self.leads.count > 0 && self.leadsTableView.isDecelerating == false && self.leadsTableView.isDragging == false {
            
            print("Refreshing table data")
            print(self.timer?.description as Any)
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.leads.count - 1
            let lastObjectId = self.leads[lastIndex].id
            
            self.getData(endpoint: "/refreshLeads.php", append: false, lastObjectId: lastObjectId) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
        }
        
    }
    
    @objc func refreshDataOnPullDown() {
        // Refresh data of the table view if the user is not scrolling
        
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && self.leads.count > 0 {
            
            print("Refreshing table data")
            print(self.timer?.description as Any)
            
            self.tableIsRefreshing = true
            self.view.showAnimatedGradientSkeleton()
            
            let lastIndex = self.leads.count - 1
            let lastObjectId = self.leads[lastIndex].id
            
            self.getData(endpoint: "/refreshLeads.php", append: false, lastObjectId: lastObjectId) {
                [weak self] in
                self?.tableIsRefreshing = false
            }
            
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

extension LeadsViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Defaults.TableViewCellIdentifiers.novaOne.rawValue
    }
    
    // Shows how many rows our table view should show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leads.count
    }
    
    // This is where we configure each cell in our table view
    // Paramater 'indexPath' represents the row number that each table view cell is contained in (Example: first appointment object has indexPath of zero)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        if self.tableIsRefreshing == false {
            // Set up cell with values if we have objects in the leads array
            let lead: Lead = self.leads[indexPath.row] // Get the object based on the row number each cell is in
            guard
                let name = lead.name,
                let companyName = lead.companyName,
                let leadBrand = lead.renterBrand,
                let dateOfInquiry = lead.dateOfInquiry
            else { return cell }
            
            // Get date of appointment as a string
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
        let lead = self.leads[indexPath.row]
        
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
        if self.appendingDataToTable == false && self.tableIsRefreshing == false && tableView.isDragging && indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            
            print("REACHED THE BOTTOM OF THE TABLE. MAKING REQUEST FOR MORE DATA...")
            self.appendingDataToTable = true
            let lastItemIndex = self.leads.count - 1
            let lastObjectId = self.leads[lastItemIndex].id
            
            // Make HTTP request for more data
            self.getData(endpoint: "/moreLeads.php", append: true, lastObjectId: lastObjectId) {
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
