//
//  UpdateCompanyHoursEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/28/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyHoursEnabledViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var updateCompanyHoursEnabledTableView: UITableView!
    var hoursOfTheDay: [EnabledOption] = [
        EnabledOption(option: "12:00 AM", selected: false),
        EnabledOption(option: "1:00 AM", selected: false),
        EnabledOption(option: "2:00 AM", selected: false),
        EnabledOption(option: "3:00 AM", selected: false),
        EnabledOption(option: "4:00 AM", selected: false),
        EnabledOption(option: "5:00 AM", selected: false),
        EnabledOption(option: "6:00 AM", selected: false),
        EnabledOption(option: "7:00 AM", selected: false),
        EnabledOption(option: "8:00 AM", selected: false),
        EnabledOption(option: "9:00 AM", selected: false),
        EnabledOption(option: "10:00 AM", selected: false),
        EnabledOption(option: "11:00 AM", selected: false),
        EnabledOption(option: "12:00 PM", selected: false),
        EnabledOption(option: "1:00 PM", selected: false),
        EnabledOption(option: "2:00 PM", selected: false),
        EnabledOption(option: "3:00 PM", selected: false),
        EnabledOption(option: "4:00 PM", selected: false),
        EnabledOption(option: "5:00 PM", selected: false),
        EnabledOption(option: "6:00 PM", selected: false),
        EnabledOption(option: "7:00 PM", selected: false),
        EnabledOption(option: "8:00 PM", selected: false),
        EnabledOption(option: "9:00 PM", selected: false),
        EnabledOption(option: "10:00 PM", selected: false),
        EnabledOption(option: "11:00 PM", selected: false),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        // Set delegate and datasource for table view
        self.updateCompanyHoursEnabledTableView.delegate = self
        self.updateCompanyHoursEnabledTableView.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Remove the modal popup view on touch of the cancel 'x' button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension UpdateCompanyHoursEnabledViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hoursOfTheDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let hour = self.hoursOfTheDay[indexPath.row] // Get the hour of the day
        
        // If the option was selected
        if hour.selected {
            cell.checkMarkImage.isHidden = false
        } else {
            cell.checkMarkImage.isHidden = true
        }
        
        cell.setup(option: hour.option)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        
        if cell.checkMarkImage.isHidden {
            cell.checkMarkImage.isHidden = false // Show the check mark image
            self.hoursOfTheDay[indexPath.row].selected = true
        } else {
            // Check mark is not hidden, so hide it
            cell.checkMarkImage.isHidden = true
            self.hoursOfTheDay[indexPath.row].selected = false
        }
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
    }
    
}
