//
//  AppointmentsContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentsContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSkeletonLoading()
        
        // Have a bit of a delay when fetching data so the data shows more smoothly
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.getAppointments()
        }
    }
    
    func showSkeletonLoading() {
        // Shows the appointments view which automatically shows a loading skeleton on viewDidLoad
        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.appointments.rawValue, containerView: self.containerView ?? UIView(), objectType: AppointmentsViewController.self, completion: nil)
    }
    
    func getAppointments() {
        // Gets appointments from the database via an HTTP request
        // and saves to CoreData
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchCustomerEntity(),
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else {
            print("Failed to obtain variables for POST request")
            return
        }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any]
        
        httpRequest.request(endpoint: "/appointments.php",
                            dataModel: [AppointmentModel].self,
                            parameters: parameters) { [weak self] (result) in
                                
                                switch result {

                                    case .success(let appointments):
                                        UIHelper.showSuccessContainer(for: self, successContainerViewIdentifier: Defaults.ViewControllerIdentifiers.appointments.rawValue, containerView: self?.containerView ?? UIView(), objectType: AppointmentsViewController.self) {
                                            appointmentsViewController in
                                            guard let appointmentsViewController = appointmentsViewController as? AppointmentsViewController else { return }
                                            appointmentsViewController.appointments = appointments
                                            appointmentsViewController.view.hideSkeleton()
                                            appointmentsViewController.appointmentTableView.reloadData()
                                        }

                                    case .failure(let error):
                                        print(error.localizedDescription)

                                        // No appointments were found or an error occurred so embed the empty
                                        // view controller
                                        UIHelper.showEmptyStateContainerViewController(for: self, containerView: self?.containerView ?? UIView())

                                }
                                
        }
        
    }

}
