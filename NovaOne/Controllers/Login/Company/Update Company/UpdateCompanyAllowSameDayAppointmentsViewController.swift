//
//  UpdateCompanyAllowSameDayAppointmentsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 8/22/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyAllowSameDayAppointmentsViewController: UpdateBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func update(allowSameDayAppointments: Bool) {
        // Update the company attribute "allow_same_day_appointments" in the database and in core data
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? CompanyDetailViewController
        else { return }
        
        let updateClosure = {
            (company: Company) in
            company.allowSameDayAppointments = allowSameDayAppointments
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { print("error getting updated company"); return }
            
            detailViewController.coreDataObjectId = updatedCompany.id
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        let allowSameDayAppointmentsDatabaseValue = allowSameDayAppointments == true ? "t" : "f"
        
        self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["allow_same_day_appointments": allowSameDayAppointmentsDatabaseValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company same day appointments has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func yesButtonTapped(_ sender: Any) {
        self.update(allowSameDayAppointments: true)
    }
    
    @IBAction func noButtonTapped(_ sender: Any) {
        self.update(allowSameDayAppointments: false)
    }
    
}
