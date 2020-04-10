//
//  UpdateDaysEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyDaysEnabledViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var updateCompanyDaysEnabledTableView: UITableView!
    var daysOfTheWeek: [EnableOption] = [
        EnableOption(option: "Sunday", selected: false),
        EnableOption(option: "Monday", selected: false),
        EnableOption(option: "Tuesday", selected: false),
        EnableOption(option: "Wednesday", selected: false),
        EnableOption(option: "Thursday", selected: false),
        EnableOption(option: "Friday", selected: false),
        EnableOption(option: "Saturday", selected: false),
    ]
    var company: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setDays()
    }
    
    func setup() {
        // Set delegates and datasource for table view
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
