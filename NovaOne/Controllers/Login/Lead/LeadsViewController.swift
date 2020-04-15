//
//  LeadsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SkeletonView

class LeadsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var leadsTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var customer: CustomerModel?
    var leads: [LeadModel] = []
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
        // Gets leads from the database via an HTTP request
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
                            dataModel: [LeadModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                let deadline = DispatchTime.now() + .milliseconds(700)
                                switch result {
                                    
                                    case .success(let leads):
                                        
                                        // Append to the leads array or make overwrite
                                        if append {
                                            self?.leads.append(contentsOf: leads)
                                        } else {
                                            self?.leads = leads
                                        }
                                        
                                        // Stop the refresh control 700 miliseconds after the data is retrieved to make it look more natrual when loading
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.refresher.endRefreshing()
                                            self?.view.hideSkeleton()
                                            self?.leadsTableView.reloadData()
                                        }
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                                            self?.view.hideSkeleton()
                                            self?.refresher.endRefreshing()
                                        }
                                    
                                }
                                
        }
    }
    
    @objc func refreshData() {
        // Refresh data on pull down of the table view
        self.setupSkeletonView()
        self.getData(endpoint: "/leads.php", append: false, lastObjectId: nil)
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
        
        let lead: LeadModel = self.leads[indexPath.row] // Get the appointment object based on the row number each cell is in
        let cellIdentifier: String = Defaults.TableViewCellIdentifiers.novaOne.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NovaOneTableViewCell // Get cell with identifier so we can use the custom cell we made
        
        let name = lead.name
        let companyName = lead.companyName
        let leadBrand = lead.renterBrand
        let dateOfInquiryDate = lead.dateOfInquiryDate
        
        // Get date of appointment as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let dateContacted: String = dateFormatter.string(from: dateOfInquiryDate)
        
        
        cell.setup(title: name, subTitleOne: companyName, subTitleTwo: leadBrand, subTitleThree: dateContacted)
        
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
        // Get last item index from data array
        let lastItemIndex = self.leads.count - 1
        
        if self.leads.count > 0 && indexPath.row == lastItemIndex {
            let lastObjectId = self.leads[lastItemIndex].id
            // Get more data
            self.loadMoreDataOnEndScroll(lastObjectId: lastObjectId)
        }

    }
    
    func loadMoreDataOnEndScroll(lastObjectId: Int) {
        // Gets more leads from the database after scrolling past
        // the last lead in the table
        print("Getting more leads from the database")
        self.getData(endpoint: "/moreLeads.php", append: true, lastObjectId: lastObjectId)
        
    }

}
