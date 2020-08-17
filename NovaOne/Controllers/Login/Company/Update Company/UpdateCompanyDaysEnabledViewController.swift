//
//  UpdateDaysEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyDaysEnabledViewController: UpdateBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var updateCompanyDaysEnabledTableView: UITableView!
    var daysOfTheWeek: [EnableOption] = [
        EnableOption(option: "Sunday", selected: false, id: 0),
        EnableOption(option: "Monday", selected: false, id: 1),
        EnableOption(option: "Tuesday", selected: false, id: 2),
        EnableOption(option: "Wednesday", selected: false, id: 3),
        EnableOption(option: "Thursday", selected: false, id: 4),
        EnableOption(option: "Friday", selected: false, id: 5),
        EnableOption(option: "Saturday", selected: false, id: 6),
    ]
    var company: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setDays()
    }
    
    func setup() {
        // Set delegates and datasource for table view
        self.updateCompanyDaysEnabledTableView.rowHeight = 44
        self.updateCompanyDaysEnabledTableView.delegate = self
        self.updateCompanyDaysEnabledTableView.dataSource = self
    }
    
    func setDays() {
        // Sets the check marks on each cell to visible based on what days
        // the user has selected perviously
        
        // If 'self.company' is a CoreData object
        if let company = self.company as? Company {
            
            guard let daysOfTheWeekEnabledString = company.daysOfTheWeekEnabled else { return }
            self.weekDayIntegerList(from: daysOfTheWeekEnabledString)
            
        } else {
            
            guard let company = self.company as? CompanyModel else { return }
            self.weekDayIntegerList(from: company.daysOfTheWeekEnabled)
            
        }
        
    }
    
    func weekDayIntegerList(from: String) {
        // Converts the week day string to a list of integers
        // and sets the 'selected' attribute to true for each EnableOption item
        
        // Convert to array of strings
        let daysOfTheWeekEnabled: [String] = from.components(separatedBy: ",")
        
        // Convert to array of integers
        let daysOfTheWeekEnabledInt = daysOfTheWeekEnabled.map({
            (weekDay: String) -> Int in
            guard let weekDay: Int = Int(weekDay) else { return 0 }
            return weekDay
        })
        
        // Loop through daysOfTheWeekEnabledInt set the 'selected' attribute to true
        // for each EnableOption item in daysOfTheWeek array
        for weekday in daysOfTheWeekEnabledInt {
            self.daysOfTheWeek[weekday].selected = true
        }
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check if an option has been selected before updating
        let optionSelected = EnableOptionHelper.optionIsSelected(options: self.daysOfTheWeek)
        if optionSelected {
            
            guard
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { print("error getting detail view controller and object id"); return }
            let updateValue = EnableOptionHelper.getSelectedOptions(options: self.daysOfTheWeek)
            
            let updateClosure = {
                (company: Company) in
                company.daysOfTheWeekEnabled = updateValue
            }
            
            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { print("error getting updated company"); return }
                
                detailViewController.company = updatedCompany
                detailViewController.setupCompanyCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["days_of_the_week_enabled": updateValue], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company showing days have been successfully updated.", successDoneHandler: successDoneHandler)
            
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select A Day", body: "Please select at least one day.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
}

extension UpdateCompanyDaysEnabledViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1 section needed in the table view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.daysOfTheWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let enableOption = self.daysOfTheWeek[indexPath.row] // Get the EnableOption object
        cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        
        let selected = cell.toggleCheckMark(cell: cell)
        self.daysOfTheWeek[indexPath.row].selected = selected // Set the EnableOption object attribute 'selected' to false or true if it was selected
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
    }
}
