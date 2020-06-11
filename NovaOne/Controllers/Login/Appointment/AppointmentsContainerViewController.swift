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
        self.showCoreDataOrRequestData()
    }
    
    func showCoreDataOrRequestData() {
        // Gets CoreData and passes it to table view OR makes a request for data if no CoreData exists
        
        if self.objectCount > 0 {
            // Get CoreData objects and pass to the next view
            print("Showing objects from Core Data")
            UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.appointments.rawValue, containerView: self.containerView, objectType: UISplitViewController.self, completion: nil)
            
        } else {
            // Get data via an HTTP request and save to coredata for the next view
            print("No Core Data. Getting objects via an HTTP request")
            self.getData()
        }
        
    }
    
    func saveToCoreData(objects: [Decodable]) {
        // Saves appointments data to CoreData and sends them to appointments view for display
        
        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.appointment.rawValue, in: PersistenceService.context) else { return }
            
            guard let appointments = objects as? [AppointmentModel] else { return }
            for appointment in appointments {
                if let coreDataAppointment = NSManagedObject(entity: entity, insertInto: PersistenceService.context) as? Appointment {
                    
                    coreDataAppointment.address = appointment.address
                    coreDataAppointment.companyId = Int32(appointment.companyId)
                    coreDataAppointment.confirmed = appointment.confirmed
                    coreDataAppointment.created = appointment.createdDate
                    coreDataAppointment.dateOfBirth = appointment.dateOfBirthDate
                    coreDataAppointment.email = appointment.email
                    coreDataAppointment.gender = appointment.gender
                    guard let id = appointment.id else { return }
                    coreDataAppointment.id = Int32(id)
                    coreDataAppointment.name = appointment.name
                    coreDataAppointment.phoneNumber = appointment.phoneNumber
                    coreDataAppointment.testType = appointment.testType
                    coreDataAppointment.time = appointment.timeDate
                    coreDataAppointment.timeZone = appointment.timeZone
                    coreDataAppointment.unitType = appointment.unitType
                    
                }
            }
        
        // Save objects to CoreData once they have been inserted into the context container
        PersistenceService.saveContext()
        
    }
    
    func getData() {
        // Gets data from the database via an HTTP request and saves to CoreData
        
        self.showSpinner(for: self.view, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/appointments.php",
                            dataModel: [AppointmentModel].self,
                            parameters: parameters) {
                                [weak self] (result) in
                                
                                switch result {
                                    
                                    case .success(let appointments):
                                        // Save data in CoreData
                                        self?.saveToCoreData(objects: appointments)
                                        
                                        // Show success screen
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.SplitViewControllerIdentifiers.appointments.rawValue, containerView: self?.containerView ?? UIView(), objectType: UISplitViewController.self, completion: nil)
                                        
                                    
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        // No appointments were found or an error occurred so show/embed the empty
                                        // view controller
                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView(), title: "No Appointments", addObjectButtonTitle: "Add Appointment") {
                                            (emptyViewController) in
                                            
                                            // Tell the empty state view controller what its parent view controller is
                                            emptyViewController.parentViewContainerController = self
                                            
                                            // Pass the addObjectHandler function and button title to the empty view controller
                                            emptyViewController.addObjectButtonHandler = {
                                                [weak self] in
                                                // Go to the add object screen
                                                guard let addAppointmentNavigationController = self?.storyboard?.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addAppointment.rawValue) as? UINavigationController else { return }
                                                self?.present(addAppointmentNavigationController, animated: true, completion: nil)
                                            }
                                        
                                    }
                                    
                                }
                                self?.removeSpinner()
        }
        
    }
}
