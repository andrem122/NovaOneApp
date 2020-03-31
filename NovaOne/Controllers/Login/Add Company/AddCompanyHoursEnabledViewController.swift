//
//  AddCompanyHoursEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyHoursEnabledViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addCompanyEnabledHoursTableView: UITableView!
    var hoursOfTheDayAM: [EnableOption] = [
        EnableOption(option: "12:00", selected: false),
        EnableOption(option: "1:00", selected: false),
        EnableOption(option: "2:00", selected: false),
        EnableOption(option: "3:00", selected: false),
        EnableOption(option: "4:00", selected: false),
        EnableOption(option: "5:00", selected: false),
        EnableOption(option: "6:00", selected: false),
        EnableOption(option: "7:00", selected: false),
        EnableOption(option: "8:00", selected: false),
        EnableOption(option: "9:00", selected: false),
        EnableOption(option: "10:00", selected: false),
        EnableOption(option: "11:00", selected: false),
    ]
    
    var hoursOfTheDayPM: [EnableOption] = [
        EnableOption(option: "12:00", selected: false),
        EnableOption(option: "1:00", selected: false),
        EnableOption(option: "2:00", selected: false),
        EnableOption(option: "3:00", selected: false),
        EnableOption(option: "4:00", selected: false),
        EnableOption(option: "5:00", selected: false),
        EnableOption(option: "6:00", selected: false),
        EnableOption(option: "7:00", selected: false),
        EnableOption(option: "8:00", selected: false),
        EnableOption(option: "9:00", selected: false),
        EnableOption(option: "10:00", selected: false),
        EnableOption(option: "11:00", selected: false),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    func setupTableView() {
        // Set delegate and datasource for table view
        self.addCompanyEnabledHoursTableView.delegate = self
        self.addCompanyEnabledHoursTableView.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func addCompanyButtonTapped(_ sender: Any) {
        // Navigate to success screen once the company has been sucessfully added
        // to the NovaOne database
        if let successViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController {
            
            successViewController.setup(title: "Company Added!", subtitle: "The company has been successfully added.")
            self.present(successViewController, animated: true, completion: nil)
            
        }
    }
    
}

extension AddCompanyHoursEnabledViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Need two sections for the table view: one for AM and one for PM hours
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hoursOfTheDayAM.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let section = indexPath.section
        switch section {
            case 0: // AM Hours Section
                let enableOption = self.hoursOfTheDayAM[indexPath.row] // Get the EnableOption object
                cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
            case 1: // PM Hours Section
                let enableOption = self.hoursOfTheDayPM[indexPath.row] // Get the EnableOption object
                cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
            default:
                return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        
        let selected = cell.toggleCheckMark(cell: cell)
        
        if indexPath.section == 0 { // For the AM hours array
           self.hoursOfTheDayAM[indexPath.row].selected = selected // Set the EnableOption object attribute 'selected' to false or true if it was selected
        } else { // For the PM hours array
            self.hoursOfTheDayPM[indexPath.row].selected = selected
        }
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0: // AM hours section
                return "AM Hours"
            case 1: // PM hours section
                return "PM Hours"
            default:
                return ""
        }
        
    }
    
}
