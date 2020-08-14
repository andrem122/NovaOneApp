//
//  UpdateCompanyAutoRespondTextViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyAutoRespondTextViewController: UpdateBaseViewController {
    
    var autoRespondText: String?
    @IBOutlet weak var textView: NovaOneTextView!
    @IBOutlet weak var updateButton: NovaOneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    func setupTextField() {
        // Sets up the text field
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        guard let autoRespondText = self.autoRespondText else { return }
        self.textView.text = autoRespondText
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let updateValue = self.textView.text else { return }
        
        if updateValue.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Auto Respond Text", body: "Please enter some text for the auto respond.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard
                let objectId = (self.updateObject as? Company)?.id,
                let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { return }
            
            let updateClosure = {
                (company: Company) in
                company.autoRespondText = updateValue
            }
            
            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { return }
                
                detailViewController.company = updatedCompany
                detailViewController.setupCompanyCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["auto_respond_text": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, successSubtitle: "Company auto respond text has been successfully updated.", successDoneHandler: successDoneHandler)
        }
        
    }
    
    
}
