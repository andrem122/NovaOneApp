//
//  UpdateLeadDateOfInquiryViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadDateOfInquiryViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

   // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateValue = DateHelper.createString(from: self.datePicker.date, format: "yyyy-MM-dd HH:mm:ssZ")
        guard
            let objectId = (self.updateObject as? Lead)?.id,
            let previousViewController = self.previousViewController as? LeadDetailViewController
        else { return }
        
        let updateClosure = {
            (lead: Lead) in
            lead.dateOfInquiry = self.datePicker.date
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
            
            previousViewController.lead = updatedLead
            previousViewController.setupObjectDetailCellsAndTitle()
            previousViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["date_of_inquiry": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, successSubtitle: "Date of inquiry has been successfully updated.", successDoneHandler: successDoneHandler)
    }
    
}
