//
//  LeadsDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LeadDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailItems: [ObjectDetailItem] = []
    var alertService: AlertService = AlertService()
    var previousViewController: UIViewController?
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: NovaOneView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewSpinner: UIActivityIndicatorView!
    var coreDataObjectId: Int32?
    weak var cachedLead: Lead?
    var lead: Lead? {
        get {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            
            guard nil == self.cachedLead else {
                return self.cachedLead!
            }
            
            // If cachedCustomer is nil, then get the customer object throught managed context object
            guard let coreDataObjectId = self.coreDataObjectId else { print("could not get core data object id - LeadDetailViewController"); return nil }
            let filter = NSPredicate(format: "id == %@", String(coreDataObjectId))
            guard let lead = PersistenceService.fetchEntity(Lead.self, filter: filter, sort: nil).first else {
                print("Lead object does not exist - LeadDetailViewController")
                return nil
            }
            
            self.cachedLead = lead
            return self.cachedLead!
            
        }
        
        set {
            self.cachedLead = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObjectDetailCellsAndTitle()
        self.setupTableView()
        self.setupTopView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            [weak self] in
            self?.hideLoadingView()
        }
    }
    
    func hideLoadingView() {
        self.loadingView.isHidden = true
        self.loadingViewSpinner.stopAnimating()
    }
    
    func setupTopView() {
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func setupTableView() {
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
        self.objectDetailTableView.rowHeight = 44;
    }
    
    func convert(lead date: Date) -> String {
        // Convert date object to a string in a date format
        
        // Get dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy | h:mm a"
        let formattedDate: String = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Set cell values for the table view
        
        guard
            let lead = self.lead,
            let name = lead.name,
            let companyName = lead.companyName,
            let dateOfInquiryDate = lead.dateOfInquiry
            else { print("could not get lead info - LeadDetailViewController"); return }
        let format = "MMM d, yyyy | h:mm a"
        let sentTextDate = lead.sentTextDate != nil ? DateHelper.createString(from: lead.sentTextDate!, format: format) : "Not Texted"
        let sentEmailDate = lead.sentEmailDate != nil ? DateHelper.createString(from: lead.sentEmailDate!, format: format) : "Not Emailed"
        let dateOfInquiry = DateHelper.createString(from: dateOfInquiryDate, format: format)
        
        // Set default values for optional types
        let phoneNumber = lead.phoneNumber != nil ? lead.phoneNumber! : "No phone"
        let unwrappedEmail = lead.email != nil ? lead.email! : "" // lead.email! returns an empty string even if it is not nil
        let email = unwrappedEmail.isEmpty ? "No email" : unwrappedEmail
        
        // Create dictionaries for cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
        let companyNameItem = ObjectDetailItem(titleValue: companyName, titleItem: .companyName)
        let dateOfInquiryItem = ObjectDetailItem(titleValue: dateOfInquiry, titleItem: .dateOfInquiry)
        let sentTextDateItem = ObjectDetailItem(titleValue: sentTextDate, titleItem: .sentTextDate)
        let sentEmailDateItem = ObjectDetailItem(titleValue: sentEmailDate, titleItem: .sentEmailDate)
        
        self.titleLabel.text = name
        self.objectDetailItems = [
            nameItem,
            phoneNumberItem,
            emailItem,
            dateOfInquiryItem,
            companyNameItem,
            sentTextDateItem,
            sentEmailDateItem]
        
        let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
        guard let customerType = customer?.customerType else { return }
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            guard let renterBrand = self.lead?.renterBrand else { return }
            let renterBrandItem = ObjectDetailItem(titleValue: renterBrand, titleItem: .renterBrand)
            self.objectDetailItems.append(renterBrandItem)
        }
        
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete?"
        let body = "Are you sure you want to delete the lead?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
            [weak self] in
            
            guard
                let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                let email = customer.email,
                let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
                let objectId = self?.coreDataObjectId,
                let lead = self?.lead
            else { return }
            
            // Remove the detail view controller from view
            guard let objectsTableViewController = self?.previousViewController as? NovaOneTableView else { print("could not get objectsTableViewController - lead detail view"); return }
            guard let containerViewControllerAsUIViewController = objectsTableViewController.parentViewContainerController else { print("could not get containerViewController - lead detail view"); return }
            guard let containerViewControllerView = objectsTableViewController.parentViewContainerController?.view else { print("could not get containerViewControllerView - lead detail view"); return }
            
            let spinnerView = containerViewControllerAsUIViewController.showSpinner(for: containerViewControllerView, textForLabel: "Deleting")
            self?.performSegue(withIdentifier: Defaults.SegueIdentifiers.unwindToLeads.rawValue, sender: self)
            
            // Delete from CoreData
            PersistenceService.context.delete(lead)
            PersistenceService.saveContext(context: nil)
            
            // Delete from NovaOne database
            let parameters: [String: Any] = ["email": email,
                                             "password": password,
                                             "columnName": "id",
                                             "objectId": objectId,
                                             "tableName": Defaults.DataBaseTableNames.leads.rawValue]
            
            let httpRequest = HTTPRequests()
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/deleteObject.php", dataModel: SuccessResponse.self, parameters: parameters) {(result) in
                switch result {
                    case .success(_):
                        // If no more objects exist, go to empty view controller else go to table view controller and reload data
                        let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue)
                        if count > 0 {
                            
                            // Return to the objects view and refresh objects
                            objectsTableViewController.refreshDataOnPullDown()
                            objectsTableViewController.parentViewContainerController?.removeSpinner(spinnerView: spinnerView)
                            
                        } else {
                            
                            guard let containerViewController = objectsTableViewController.parentViewContainerController as? NovaOneObjectContainer else { print("could not get containerViewController - lead detail view controller"); return }
                            
                            UIHelper.showEmptyStateContainerViewController(for: containerViewController as? UIViewController, containerView: containerViewController.containerView ?? UIView(), title: "No Leads", addObjectButtonTitle: "Add Lead") {
                                (emptyViewController) in
                                
                                objectsTableViewController.parentViewContainerController?.removeSpinner(spinnerView: spinnerView)
                                // Tell the empty state view controller what its parent view controller is
                                emptyViewController.parentViewContainerController = containerViewController as? UIViewController
                                
                                // Pass the addObjectHandler function and button title to the empty view controller
                                emptyViewController.addObjectButtonHandler = {
                                    // Go to the add object screen
                                    let addLeadStoryboard = UIStoryboard(name: Defaults.StoryBoards.addLead.rawValue, bundle: .main)
                                    guard
                                        let addLeadNavigationController = addLeadStoryboard.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addLead.rawValue) as? UINavigationController,
                                        let addLeadCompanyViewController = addLeadNavigationController.viewControllers.first as? AddLeadCompanyViewController
                                    else { return }
                                    
                                    addLeadCompanyViewController.embeddedViewController = emptyViewController
                                    
                                    // Do NOT present from self (leadDetailViewController in this case) because we are dismissing it and it will no longer be available, so we can't call any methods on a nil object
                                    (containerViewController as? UIViewController)?.present(addLeadNavigationController, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                    case .failure(let error):
                        guard let containerViewController = containerViewControllerAsUIViewController as? NovaOneObjectContainer else { return }
                        let popUpOkViewController = containerViewController.alertService.popUpOk(title: "Error", body: error.localizedDescription)
                        containerViewControllerAsUIViewController.present(popUpOkViewController, animated: true, completion: nil)
                }
            }
        }, cancelHandler: {
            print("Action canceled")
        })
        
        self.present(popUpViewController, animated: true, completion: nil)
    }
    
}

extension LeadDetailViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailItem = self.objectDetailItems[indexPath.row]
        cell.objectDetailItem = objectDetailItem
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let updateLeadStoryboard = UIStoryboard(name: Defaults.StoryBoards.updateLead.rawValue, bundle: .main)
        
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        switch titleItem {
            case .name:
                guard let updateLeadNameViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadName.rawValue) as? UpdateLeadNameViewController else { return }
                
                updateLeadNameViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadNameViewController.previousViewController = self
                updateLeadNameViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadNameViewController, animated: true)
            case .email:
                guard let updateLeadEmailViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadEmail.rawValue) as? UpdateLeadEmailViewController else { return }
                
                updateLeadEmailViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadEmailViewController.previousViewController = self
                updateLeadEmailViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadEmailViewController, animated: true)
            case .phoneNumber:
                guard let updateLeadPhoneViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadPhone.rawValue) as? UpdateLeadPhoneViewController else { return }
                
                updateLeadPhoneViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadPhoneViewController.previousViewController = self
                updateLeadPhoneViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadPhoneViewController, animated: true)
            case .dateOfInquiry:
                guard let updateLeadDateOfInquiryViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadDateOfInquiry.rawValue) as? UpdateLeadDateOfInquiryViewController else { return }
                
                updateLeadDateOfInquiryViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadDateOfInquiryViewController.previousViewController = self
                updateLeadDateOfInquiryViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadDateOfInquiryViewController, animated: true)
            case .sentTextDate:
                guard let updateLeadSentTextDateViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadSentTextDate.rawValue) as? UpdateLeadSentTextDateViewController else { return }
                
                updateLeadSentTextDateViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadSentTextDateViewController.previousViewController = self
                updateLeadSentTextDateViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadSentTextDateViewController, animated: true)
            case .sentEmailDate:
                guard let updateLeadSentEmailDateViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadSentEmailDate.rawValue) as? UpdateLeadSentEmailDateViewController else { return }
                
                updateLeadSentEmailDateViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadSentEmailDateViewController.previousViewController = self
                updateLeadSentEmailDateViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadSentEmailDateViewController, animated: true)
            case .companyName:
                guard let updateLeadCompanyViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadCompany.rawValue) as? UpdateLeadCompanyViewController else { return }
                
                updateLeadCompanyViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadCompanyViewController.previousViewController = self
                updateLeadCompanyViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadCompanyViewController, animated: true)
            case .renterBrand:
                guard let updateLeadRenterViewController = updateLeadStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateLeadRenterBrand.rawValue) as? UpdateLeadRenterBrandViewController else { return }
                
                updateLeadRenterViewController.updateCoreDataObjectId = self.coreDataObjectId
                updateLeadRenterViewController.previousViewController = self
                updateLeadRenterViewController.modalPresentationStyle = .fullScreen
                
                self.present(updateLeadRenterViewController, animated: true)
            default:
                print("No cases matched")
        }
    }

}

