//
//  AppointmentsContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class AppointmentsContainerViewController: UIViewController {
    
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    var objectCount: Int = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.appointment.rawValue)
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.showCoreDataOrRequestData()
    }
    
//    func showCoreDataOrRequestData() {
//        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
//
//        if self.objectCount > 0 {
//            // Get CoreData objects and pass to the next view
//            print("Showing objects from Core Data")
//            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.appointments.rawValue, containerView: self.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
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
//        // Saves appointments data to CoreData and sends them to appointments view for display
//
//        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.appointment.rawValue, in: PersistenceService.context) else { return }
//
//            guard let appointments = objects as? [AppointmentModel] else { return }
//            for appointment in appointments {
//                if let coreDataAppointment = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Appointment {
//
//                    coreDataAppointment.address = appointment.address
//                    coreDataAppointment.companyId = Int32(appointment.companyId)
//                    coreDataAppointment.confirmed = appointment.confirmed
//                    coreDataAppointment.created = appointment.createdDate
//                    coreDataAppointment.dateOfBirth = appointment.dateOfBirthDate
//                    coreDataAppointment.email = appointment.email
//                    coreDataAppointment.gender = appointment.gender
//                    coreDataAppointment.id = Int32(appointment.id)
//                    coreDataAppointment.name = appointment.name
//                    coreDataAppointment.phoneNumber = appointment.phoneNumber
//                    coreDataAppointment.testType = appointment.testType
//                    coreDataAppointment.time = appointment.timeDate
//                    coreDataAppointment.timeZone = appointment.timeZone
//                    coreDataAppointment.unitType = appointment.unitType
//
//                    let predicate = NSPredicate(format: "id == %@", String(appointment.companyId))
//                    coreDataAppointment.company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
//
//
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
//        let coreDataAppointments = PersistenceService.fetchEntity(Appointment.self, filter: nil, sort: sortDescriptors)
//
//        guard let objectsTableViewController = self.storyboard?.instantiateViewController(identifier: Defaults.TableViewIdentifiers.appointments.rawValue) as? AppointmentsTableViewController else { return }
//        objectsTableViewController.objects = coreDataAppointments
//        objectsTableViewController.filteredObjects = coreDataAppointments
//    }
//
//    func getData(success: @escaping () -> Void) {
//        // Gets data from the database via an HTTP request and saves to CoreData
//
//        self.showSpinner(for: self.view, textForLabel: nil)
//
//        let httpRequest = HTTPRequests()
//        guard
//            let customer = PersistenceService.fetchCustomerEntity(),
//            let email = customer.email,
//            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
//        else { return }
//        let customerUserId = customer.id
//
//        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
//                                         "email": email as Any,
//                                         "password": password as Any]
//
//        httpRequest.request(endpoint: "/appointments.php",
//                            dataModel: [AppointmentModel].self,
//                            parameters: parameters) {
//                                [weak self] (result) in
//
//                                switch result {
//
//                                    case .success(let appointments):
//
//                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.appointments.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self) {
//                                            [weak self] (appointmentsSplitViewController) in
//
//                                            // Save data in CoreData
//                                            self?.saveToCoreData(objects: appointments)
//                                            success()
//
//                                    }
//
//                                    case .failure(let error):
//                                        print(error.localizedDescription)
//                                        // No appointments were found or an error occurred so show/embed the empty
//                                        // view controller
//                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Appointments") {
//                                            (emptyViewController) in
//
//                                            // Tell the empty state view controller what its parent view controller is
//                                            emptyViewController.parentViewContainerController = self
//
//                                    }
//
//                                }
//                self?.removeSpinner() // Call inside the closure because the request is asynchronous and if called outside
//                                      // the closure, the spinner will be removed too fast before it can show
//        }
//    }
}
