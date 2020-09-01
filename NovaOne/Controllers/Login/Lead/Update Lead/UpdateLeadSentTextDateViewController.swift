//
//  UpdateLeadSentTextDateViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadSentTextDateViewController: UpdateBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateValue = DateHelper.createString(from: self.dateTimePicker.date, format: "yyyy-MM-dd HH:mm:ssZ")
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? LeadDetailViewController
        else { return }
        
        let updateClosure = {
            (lead: Lead) in
            lead.sentTextDate = self.dateTimePicker.date
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
            detailViewController.lead = updatedLead
            detailViewController.coreDataObjectId = objectId
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["sent_text_date": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Sent text date has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
    }
    
}
