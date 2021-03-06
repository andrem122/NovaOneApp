//
//  CompaniesContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class CompaniesContainerViewController: UIViewController, NovaOneObjectContainer {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    var alertService = AlertService()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showCoreDataOrRequestData()
    }
    
    func showCoreDataOrRequestData() {
               // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
        let objectCount: Int = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)
        if objectCount > 0 {
            // Get CoreData objects and pass to the next view
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self.containerView, objectType: UISplitViewController.self) {
                [weak self] (viewController) in
                
                guard let splitViewController = viewController as? UISplitViewController else { return }
                guard let objectsTableNavigationController = splitViewController.viewControllers.first as? UINavigationController else { return }
                guard let objectsTableController = objectsTableNavigationController.viewControllers.first as? NovaOneTableView else { return }
                objectsTableController.parentViewContainerController = self
            }
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            self.getData()
        }
        
    }
    
    func saveToCoreData(objects: [Decodable]) {
        // Saves objects data to CoreData
        let context = PersistenceService.privateChildManagedObjectContext()
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: context) else { return }
        
        guard let companies = objects as? [CompanyModel] else { return }
        for company in companies {
            if let coreDataCompany = NSManagedObject(entity: entity, insertInto: context) as? Company {
                
                coreDataCompany.address = company.address
                coreDataCompany.city = company.city
                coreDataCompany.created = company.createdDate
                coreDataCompany.customerUserId = Int32(company.customerUserId)
                coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
                coreDataCompany.allowSameDayAppointments = company.allowSameDayAppointments
                coreDataCompany.email = company.email
                coreDataCompany.autoRespondNumber = company.autoRespondNumber
                coreDataCompany.autoRespondText = company.autoRespondText
                coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
                coreDataCompany.id = Int32(company.id)
                coreDataCompany.name = company.name
                coreDataCompany.phoneNumber = company.phoneNumber
                coreDataCompany.shortenedAddress = company.shortenedAddress
                coreDataCompany.state = company.state
                coreDataCompany.zip = company.zip
                
            }
        }
        
        // Save objects to CoreData once they have been inserted into the context container
        PersistenceService.saveContext(context: context)
    }
    
    func getData() {
        // Gets data from the database via an HTTP request and saves to CoreData
        
        let spinnerView = self.showSpinner(for: self.view, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
            self.removeSpinner(spinnerView: spinnerView)
            return
        }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/companies.php",
                            dataModel: [CompanyModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
            switch result {
                
                case .success(let companies):
                    // Save data in CoreData
                    self?.saveToCoreData(objects: companies)
                    
                    // Show success screen
                    UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self) {
                        [weak self] (viewController) in
                        
                        guard let splitViewController = viewController as? UISplitViewController else { return }
                        guard let objectsTableNavigationController = splitViewController.viewControllers.first as? UINavigationController else { return }
                        guard let objectsTableController = objectsTableNavigationController.viewControllers.first as? NovaOneTableView
                        else {
                            self?.removeSpinner(spinnerView: spinnerView)
                            return
                        }
                        objectsTableController.parentViewContainerController = self
                    }
                    
                
                case .failure(_):
                    // No objects were found or an error occurred so show/embed the empty
                    // view controller
                    UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Companies", addObjectButtonTitle: "Add Company") {
                        (emptyViewController) in
                        
                        // Tell the empty state view controller what its parent view controller is
                        emptyViewController.parentViewContainerController = self
                        
                        // Pass the addObjectHandler function and button title to the empty view controller
                        emptyViewController.addObjectButtonHandler = {
                            [weak self] in
                            // Go to the add object screen
                            let addCompanyStoryboard = UIStoryboard(name: Defaults.StoryBoards.addCompany.rawValue, bundle: .main)
                            guard
                                let addCompanyNavigationController = addCompanyStoryboard.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addCompany.rawValue) as? UINavigationController
                            else {
                                print("could not get add company navigation controller - CompaniesContainerViewController")
                                self?.removeSpinner(spinnerView: spinnerView)
                                return
                            }
                            
                            guard
                                let addCompanyNameViewController = addCompanyNavigationController.viewControllers.first as? AddCompanyNameViewController
                            else {
                                print("could not get addCompanyNameViewController view controller - CompaniesContainerViewController")
                                self?.removeSpinner(spinnerView: spinnerView)
                                return
                            }
                            
                            // Pass embedded view controller
                            addCompanyNameViewController.embeddedViewController = emptyViewController
                            
                            self?.present(addCompanyNavigationController, animated: true, completion: nil)
                        }
                    
                }
                
            }
            self?.removeSpinner(spinnerView: spinnerView)
        }
    }

}
