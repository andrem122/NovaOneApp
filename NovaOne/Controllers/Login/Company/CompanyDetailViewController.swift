//
//  CompanyDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SafariServices

class CompanyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailItems: [ObjectDetailItem] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var topView: NovaOneView!
    var alertService = AlertService()
    var previousViewController: UIViewController?
    var coreDataObjectId: Int32?
    @IBOutlet weak var loadingViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    weak var cachedCompany: Company?
    var company: Company? {
        get {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            
            guard nil == self.cachedCompany else {
                return self.cachedCompany!
            }
            
            // If cachedCustomer is nil, then get the customer object throught managed context object
            guard let coreDataObjectId = self.coreDataObjectId else { print("could not get core data object id - CompanyDetailViewController"); return nil }
            let filter = NSPredicate(format: "id == %@", String(coreDataObjectId))
            guard let company = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else {
                print("Company object does not exist -CompanyDetailViewController")
                return nil
            }
            
            self.cachedCompany = company
            return self.cachedCompany!
            
        }
        
        set {
            self.cachedCompany = newValue
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupTopView()
        self.setupNavigationBackButton()
        self.setupObjectDetailCellsAndTitle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            [weak self] in
            self?.hideLoadingView()
        }
    }
    
    func hideLoadingView() {
        self.loadingView.isHidden = true
        self.loadingViewSpinner.stopAnimating()
    }
    
    func setupTableView() {
        self.objectDetailTableView.rowHeight = 44
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
    }
    
    func setupTopView() {
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Sets up the cell properties for each company cell and title for the view
        // Title
        guard
            let company = self.company,
            let name = company.name,
            let phoneNumber = company.phoneNumber,
            let email = company.email,
            let address = company.shortenedAddress
        else { return }
        
        self.titleLabel.text = name
        let autoRespondNumber = company.autoRespondNumber != nil ? company.autoRespondNumber! : "No Auto Respond"
        let allowSameDayAppointments = company.allowSameDayAppointments == true ? "Yes" : "No"
        
        // Cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let addressItem = ObjectDetailItem(titleValue: address, titleItem: .address)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
        let appointmentLinkItem = ObjectDetailItem(titleValue: "", titleItem: .appointmentLink)
        let allowSameDayAppointmentsItem = ObjectDetailItem(titleValue: allowSameDayAppointments, titleItem: .allowSameDayAppointments)
        let daysOfTheWeekItem = ObjectDetailItem(titleValue: "", titleItem: .showingDays)
        let hoursOfTheDayItem = ObjectDetailItem(titleValue: "", titleItem: .showingHours)
        let autoRespondNumberItem = ObjectDetailItem(titleValue: autoRespondNumber, titleItem: .autoRespondNumber)
        let autoRespondTextItem = ObjectDetailItem(titleValue: "", titleItem: .autoRespondText)
        
        self.objectDetailItems = [nameItem,
                                  addressItem,
                                  phoneNumberItem,
                                  emailItem,
                                  appointmentLinkItem,
                                  allowSameDayAppointmentsItem,
                                  daysOfTheWeekItem,
                                  hoursOfTheDayItem,
                                  autoRespondNumberItem,
                                  autoRespondTextItem]
    }
    
    func setupNavigationBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // User must have at least one company and cannot delete the last one
        let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
        if count == 1 {
            // Popup a ok view controller telling the user they cannot delete the last company
            let popUpOkViewController = self.alertService.popUpOk(title: "Cannot Delete", body: "You must have at least one company to operate on NovaOne.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            // Set text for pop up view controller
            let title = "Delete?"
            let body = "Are you sure you want to delete the company? This will delete all lead and appointment data with the company as well."
            let buttonTitle = "Delete"
            
            let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
                [weak self] in
                
                guard
                    let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                    let email = customer.email,
                    let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
                    let objectId = self?.company?.id,
                    let company = self?.company
                else { return }
                
                // Remove the detail view controller from view
                guard let objectsTableViewController = self?.previousViewController as? NovaOneTableView else { print("could not get objectsTableViewController - company detail view"); return }
                guard let containerViewControllerAsUIViewController = objectsTableViewController.parentViewContainerController else { print("could not get containerViewController - company detail view"); return }
                guard let containerViewControllerView = objectsTableViewController.parentViewContainerController?.view else { print("could not get containerViewControllerView - company detail view"); return }
                
                
                let spinnerView = containerViewControllerAsUIViewController.showSpinner(for: containerViewControllerView, textForLabel: "Deleting")
                self?.performSegue(withIdentifier: Defaults.SegueIdentifiers.unwindToCompanies.rawValue, sender: self)
                
                // Delete from CoreData
                PersistenceService.context.delete(company)
                PersistenceService.saveContext(context: nil)
                
                // Delete from NovaOne database
                let parameters: [String: Any] = ["email": email,
                                                 "password": password,
                                                 "columnName": "id",
                                                 "objectId": objectId,]
                
                let httpRequest = HTTPRequests()
                httpRequest.request(url: Defaults.Urls.api.rawValue + "/deleteCompany.php", dataModel: SuccessResponse.self, parameters: parameters) {(result) in
                    
                    let setFirstItem = UIDevice.current.userInterfaceIdiom == .pad ? true : false
                    switch result {
                        case .success(_):
                            // If no more objects exist, go to empty view controller else go to table view controller and reload data
                            let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
                            if count > 0 {
                                
                                // Return to the objects view and refresh objects
                                objectsTableViewController.spinnerView = spinnerView // Pass spinner view to table view so we can remove it AFTER the data loads
                                objectsTableViewController.refreshDataOnPullDown(setFirstItem: setFirstItem)
                                
                            } else {
                                
                                // No more objects to show so go to the empty view controller screen
                                guard let containerViewController = containerViewControllerAsUIViewController as? NovaOneObjectContainer else { return }
                                
                                UIHelper.showEmptyStateContainerViewController(for: containerViewController as? UIViewController, containerView: containerViewController.containerView ?? UIView(), title: "No Companies", addObjectButtonTitle: "Add Company") {
                                    (emptyViewController) in
                                    
                                    // Tell the empty state view controller what its parent view controller is
                                    emptyViewController.parentViewContainerController = containerViewController as? UIViewController
                                    
                                    // Pass the addObjectHandler function and button title to the empty view controller
                                    emptyViewController.addObjectButtonHandler = {
                                        // Go to the add object screen
                                        let addCompanyStoryboard = UIStoryboard(name: Defaults.StoryBoards.addCompany.rawValue, bundle: .main)
                                        guard
                                            let addCompanyNavigationController = addCompanyStoryboard.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addCompany.rawValue) as? UINavigationController,
                                            let addCompanyCompanyViewController = addCompanyNavigationController.viewControllers.first as? AddCompanyNameViewController
                                        else { return }
                                        
                                        addCompanyCompanyViewController.embeddedViewController = emptyViewController
                                        
                                        (containerViewController as? UIViewController)?.present(addCompanyNavigationController, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                            }
                        case .failure(let error):
                            guard let containerViewController = containerViewControllerAsUIViewController as? NovaOneObjectContainer else { return }
                            let popUpOkViewController = containerViewController.alertService.popUpOk(title: "Error", body: error.localizedDescription)
                            containerViewControllerAsUIViewController.present(popUpOkViewController, animated: true, completion: nil)
                    }
                    
                    // Remove the spinner here if not on iPad devices
                    if setFirstItem == false {
                        containerViewControllerAsUIViewController.removeSpinner(spinnerView: spinnerView)
                    }
                }
            }, cancelHandler: {
                print("Action canceled")
            })
            
            self.present(popUpViewController, animated: true, completion: nil)
        }
    }

}

extension CompanyDetailViewController {
    
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
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Get company title based on which row the user taps on
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        let updateCompanyStoryboard = UIStoryboard(name: Defaults.StoryBoards.updateCompany.rawValue, bundle: .main)
        
        // Get update view controller based on which cell the user clicked on
        switch titleItem {
            
            case .address:
                if let updateCompanyAddressViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAddress.rawValue) as? UpdateCompanyAddressViewController {
                    
                    updateCompanyAddressViewController.updateCoreDataObjectId = self.coreDataObjectId
                    updateCompanyAddressViewController.previousViewController = self
                    updateCompanyAddressViewController.modalPresentationStyle = .fullScreen
                    
                    self.present(updateCompanyAddressViewController, animated: true, completion: nil)
                    
                }
                    
                case .phoneNumber:
                    if let updateCompanyPhoneViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyPhone.rawValue) as? UpdateCompanyPhoneViewController {
                        
                        updateCompanyPhoneViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyPhoneViewController.previousViewController = self
                        updateCompanyPhoneViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyPhoneViewController, animated: true, completion: nil)
                        
                    }
                    
                case .name:
                    if let updateCompanyNameViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyName.rawValue) as? UpdateCompanyNameViewController {
                        
                        updateCompanyNameViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyNameViewController.previousViewController = self
                        updateCompanyNameViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyNameViewController, animated: true, completion: nil)
                        
                    }
                    
                case .email:
                    if let updateCompanyEmailViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyEmail.rawValue) as? UpdateCompanyEmailViewController {
                        
                        updateCompanyEmailViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyEmailViewController.previousViewController = self
                        updateCompanyEmailViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyEmailViewController, animated: true, completion: nil)
                        
                    }
            
                case .allowSameDayAppointments:
                   if let updateCompanyAllowSameDayAppointmentsViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAllowSameDayAppointments.rawValue) as? UpdateCompanyAllowSameDayAppointmentsViewController {
                       
                       updateCompanyAllowSameDayAppointmentsViewController.updateCoreDataObjectId = self.coreDataObjectId
                       updateCompanyAllowSameDayAppointmentsViewController.previousViewController = self
                       updateCompanyAllowSameDayAppointmentsViewController.modalPresentationStyle = .fullScreen
                       
                       self.present(updateCompanyAllowSameDayAppointmentsViewController, animated: true, completion: nil)
                       
                   }
                    
                case .showingDays:
                    if let updateCompanyDaysEnabledViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyDaysEnabled.rawValue) as? UpdateCompanyDaysEnabledViewController {
                        
                        updateCompanyDaysEnabledViewController.company = company
                        updateCompanyDaysEnabledViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyDaysEnabledViewController.previousViewController = self
                        updateCompanyDaysEnabledViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyDaysEnabledViewController, animated: true, completion: nil)
                        
                    }
                    
                case .showingHours:
                    if let updateCompanyHoursEnabledViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyHoursEnabled.rawValue) as? UpdateCompanyHoursEnabledViewController {
                        
                        updateCompanyHoursEnabledViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyHoursEnabledViewController.previousViewController = self
                        updateCompanyHoursEnabledViewController.company = self.company
                        updateCompanyHoursEnabledViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyHoursEnabledViewController, animated: true, completion: nil)
                        
                    }
                    
                case .appointmentLink:
                    guard
                        let companyId = self.coreDataObjectId
                    else { return }
                    let appointmentLink = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
                    
                    // Open appointment link web page
                    guard let url = URL(string: appointmentLink) else { return }
                    let webViewController = SFSafariViewController(url: url)
                    self.present(webViewController, animated: true, completion: nil)
                    
                case .autoRespondNumber:
                    guard
                        let autoRespondNumber = self.company?.autoRespondNumber
                    else { return }
                    UIPasteboard.general.string = autoRespondNumber
                    
                    // Show popup confirming that text has been copied
                    let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "Auto respond number has been copied to clipboard successfully.")
                    self.present(popUpOkViewController, animated: true, completion: nil)
                    
                case .autoRespondText:
                    if let updateCompanyAutoRespondTextViewController = updateCompanyStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.updateCompanyAutoRespondText.rawValue) as? UpdateCompanyAutoRespondTextViewController {
                        
                        guard let company = self.company else { return }
                        let autoRespondText = company.autoRespondText != nil ? company.autoRespondText! : "Update auto respond text..."
                        
                        updateCompanyAutoRespondTextViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateCompanyAutoRespondTextViewController.previousViewController = self
                        updateCompanyAutoRespondTextViewController.autoRespondText = autoRespondText
                        updateCompanyAutoRespondTextViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateCompanyAutoRespondTextViewController, animated: true, completion: nil)
                        
                    }
                
                default:
                print("No cases matched")
            
        }
        
    }
    
}
