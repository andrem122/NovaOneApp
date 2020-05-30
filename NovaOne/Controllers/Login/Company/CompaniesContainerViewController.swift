//
//  CompaniesContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class CompaniesContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    var objectCount: Int = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.company.rawValue)

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.showCoreDataOrRequestData()
    }
    
//    func showCoreDataOrRequestData() {
//        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
//        // We don't need to make an http request because we grab company data when the user logs in
//
//        if self.objectCount > 0 {
//            // Get CoreData objects and pass to the next view
//            print("Showing objects from Core Data")
//            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
//
//        } else {
//            // Get data via an HTTP request and save to coredata for the next view
//            print("No Core Data. Getting objects via an HTTP request")
//            self.getData {
//                [weak self] in
//                self?.getCoreData()
//            }
//        }
//    }
//
//    func saveToCoreData(objects: [Decodable]) {
//        // Saves companies data to CoreData and sends them to companies view for display
//
//        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.company.rawValue, in: PersistenceService.context) else { return }
//
//            guard let companies = objects as? [CompanyModel] else { return }
//            for company in companies {
//                if let coreDataCompany = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Company {
//
//                    coreDataCompany.address = company.address
//                    coreDataCompany.city = company.city
//                    coreDataCompany.created = company.createdDate
//                    coreDataCompany.customerUserId = Int32(company.customerUserId)
//                    coreDataCompany.daysOfTheWeekEnabled = company.daysOfTheWeekEnabled
//                    coreDataCompany.email = company.email
//                    coreDataCompany.hoursOfTheDayEnabled = company.hoursOfTheDayEnabled
//                    coreDataCompany.id = Int32(company.id)
//                    coreDataCompany.name = company.name
//                    coreDataCompany.phoneNumber = company.phoneNumber
//                    coreDataCompany.shortenedAddress = company.shortenedAddress
//                    coreDataCompany.state = company.state
//                    coreDataCompany.zip = company.zip
//
//                    coreDataCompany.customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
//
//                    // Add appointments
//                    if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.appointment.rawValue) > 0 {
//                        let predicate = NSPredicate(format: "companyId == %@", String(company.id))
//                        let appointments = NSSet(array: PersistenceService.fetchEntity(Appointment.self, filter: predicate, sort: nil))
//                        coreDataCompany.addToAppointments(appointments)
//                    }
//
//                    // Add leads
//                    if PersistenceService.fetchCount(for: Defaults.CoreDataEntities.lead.rawValue) > 0 {
//                        let predicate = NSPredicate(format: "companyId == %@", String(company.id))
//                        let leads = NSSet(array: PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil))
//                        coreDataCompany.addToLeads(leads)
//                    }
//                }
//            }
//
//            // Save objects to CoreData once they have been inserted into the context container
//            PersistenceService.saveContext()
//    }
//
//    func getCoreData() {
//        // Gets core data and sends to the objects table view
//        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
//        let coreDataLeads = PersistenceService.fetchEntity(Company.self, filter: nil, sort: sortDescriptors)
//
//        guard let objectsTableViewController = self.storyboard?.instantiateViewController(identifier: Defaults.TableViewIdentifiers.leads.rawValue) as? CompaniesTableViewController else { return }
//        objectsTableViewController.objects = coreDataLeads
//        objectsTableViewController.filteredObjects = coreDataLeads
//    }
//
//        func getData(success: @escaping () -> Void) {
//            // Gets data from the database via an HTTP request and saves to CoreData
//
//            self.showSpinner(for: self.view, textForLabel: nil)
//
//            let httpRequest = HTTPRequests()
//            guard
//                let customer = PersistenceService.fetchCustomerEntity(),
//                let email = customer.email,
//                let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
//            else { return }
//            let customerUserId = customer.id
//
//            let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
//                                             "email": email as Any,
//                                             "password": password as Any]
//
//            httpRequest.request(endpoint: "/companies.php",
//                                dataModel: [CompanyModel].self,
//                                parameters: parameters) {
//                                    [weak self] (result) in
//
//                                    switch result {
//
//                                        case .success(let companies):
//
//                                            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.companies.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self) {
//                                                [weak self] (companiesSplitViewController) in
//
//                                                // Save data in CoreData
//                                                self?.saveToCoreData(objects: companies)
//                                                success()
//
//                                        }
//
//                                        case .failure(let error):
//                                            print(error.localizedDescription)
//                                            // No companies were found or an error occurred so show/embed the empty
//                                            // view controller
//                                            UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Companies") {
//                                                (emptyViewController) in
//
//                                                // Tell the empty state view controller what its parent view controller is
//                                                emptyViewController.parentViewContainerController = self
//
//                                        }
//
//                                    }
//                    self?.removeSpinner() // Call inside the closure because the request is asynchronous and if called outside
//                                          // the closure, the spinner will be removed too fast before it can show
//            }
//    }

}
