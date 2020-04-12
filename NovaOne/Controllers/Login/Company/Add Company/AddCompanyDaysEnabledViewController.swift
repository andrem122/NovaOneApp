//
//  AddCompanyDaysEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyDaysEnabledViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var addCompanyDaysEnabledTableView: UITableView!
    var userIsSigningUp: Bool = false // A Boolean that indicates whether or not the current user is new and signing up
    
    var daysOfTheWeek: [EnableOption] = [
        EnableOption(option: "Sunday", selected: false, id: nil),
        EnableOption(option: "Monday", selected: false, id: nil),
        EnableOption(option: "Tuesday", selected: false, id: nil),
        EnableOption(option: "Wednesday", selected: false, id: nil),
        EnableOption(option: "Thursday", selected: false, id: nil),
        EnableOption(option: "Friday", selected: false, id: nil),
        EnableOption(option: "Saturday", selected: false, id: nil),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        // Set delegates and datasource for table view
        self.addCompanyDaysEnabledTableView.delegate = self
        self.addCompanyDaysEnabledTableView.dataSource = self
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the user is signing up, pass the userIsSigningUp Boolean value to the
        // hours enabled view controller
        guard let addCompanyHoursEnabledViewController = segue.destination as? AddCompanyHoursEnabledViewController else { return }
        addCompanyHoursEnabledViewController.userIsSigningUp = self.userIsSigningUp
    }

}

extension AddCompanyDaysEnabledViewController {
    
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
