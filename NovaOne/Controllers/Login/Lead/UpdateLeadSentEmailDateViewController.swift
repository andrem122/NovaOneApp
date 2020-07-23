//
//  UpdateLeadSentEmailDateViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadSentEmailDateViewController: UpdateBaseViewController {
    // MARK: Properties
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateValue = DateHelper.createString(from: self.dateTimePicker.date, format: "yyyy-MM-dd HH:mm:ssZ")
        guard
            let objectId = (self.updateObject as? Lead)?.id,
            let previousViewController = self.previousViewController as? LeadDetailViewController
        else { return }
        
        let updateClosure = {
            (lead: Lead) in
            lead.sentEmailDate = self.dateTimePicker.date
        }
        
        let successDoneHandler = {
            [weak self] in
            
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
            
            previousViewController.lead = updatedLead
            previousViewController.setupObjectDetailCellsAndTitle()
            previousViewController.objectDetailTableView.reloadData()
            
            self?.removeSpinner()
            
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["sent_email_date": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, successSubtitle: "Sent email date has been successfully updated.", successDoneHandler: successDoneHandler)
    }
    
}