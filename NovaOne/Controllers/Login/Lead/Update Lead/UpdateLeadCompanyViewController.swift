//
//  UpdateLeadCompanyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadCompanyViewController: UpdateBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateButton: NovaOneButton!
    var options: [EnableOption] = []
    var companies: [Company]?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCompanies()
        self.setupTableView()
    }
    
    func setupTableView() {
        self.tableView.rowHeight = 44
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func getCompanies() {
        // Get customer companies from CoreData
        // Set up attributes for options array
        let companies = PersistenceService.fetchEntity(Company.self, filter: nil, sort: nil)
        for company in companies {
            guard let companyName = company.name else { return }
            let option = EnableOption(option: companyName, selected: false, id: Int(company.id))
            self.options.append(option)
        }
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check if item was selected in table
        if EnableOptionHelper.optionIsSelected(options: self.options) == true {
            guard
                let objectId = self.updateCoreDataObjectId,
                let previousViewController = self.previousViewController as? LeadDetailViewController
            else { return }
            
            let selectedOption = options.filter { (option) -> Bool in
                option.selected == true
            }.first
            
            guard let selectedOptionId = selectedOption?.id else { return }
            let updatedCompanyName = selectedOption?.option
            let updatedCompanyId = Int32(selectedOptionId)
            
            let updateClosure = {
                (lead: Lead) in
                lead.companyName = updatedCompanyName
                lead.companyId = updatedCompanyId
            }
            
            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
                
                previousViewController.lead = updatedLead
                previousViewController.setupObjectDetailCellsAndTitle()
                previousViewController.objectDetailTableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["company_id": updatedCompanyId], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select Company", body: "Please select a company.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension UpdateLeadCompanyViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Deselect all other selections. Only one company may be selected
        for (count, _) in self.options.enumerated() {
            self.options[count].selected = false
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        let selected = cell.toggleCheckMark(cell: cell)
        self.options[indexPath.row].selected = selected
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let enableOption = self.options[indexPath.row] // Get the EnableOption object
        cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
        return cell
        
    }
}
