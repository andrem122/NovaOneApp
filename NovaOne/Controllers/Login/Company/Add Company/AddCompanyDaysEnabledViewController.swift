//
//  AddCompanyDaysEnabledViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyDaysEnabledViewController: AddCompanyBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var addCompanyDaysEnabledTableView: UITableView!
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue
        
        let userInfo = [AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    var daysOfTheWeek: [EnableOption] = [
        EnableOption(option: "Sunday", selected: false, id: 0),
        EnableOption(option: "Monday", selected: false, id: 1),
        EnableOption(option: "Tuesday", selected: false, id: 2),
        EnableOption(option: "Wednesday", selected: false, id: 3),
        EnableOption(option: "Thursday", selected: false, id: 4),
        EnableOption(option: "Friday", selected: false, id: 5),
        EnableOption(option: "Saturday", selected: false, id: 6),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextFields()
    }

    
    func setupTextFields() {
        // Set delegates and datasource for table view
        self.addCompanyDaysEnabledTableView.delegate = self
        self.addCompanyDaysEnabledTableView.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        if EnableOptionHelper.optionIsSelected(options: self.daysOfTheWeek) == true {
            
            guard let addCompanyHoursEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyHoursEnabled.rawValue) as? AddCompanyHoursEnabledViewController else { return }
            
            // Get selected options and pass objects
            let selectedOptionsString = EnableOptionHelper.getSelectedOptions(options: self.daysOfTheWeek)
            self.company?.daysOfTheWeekEnabled = selectedOptionsString
            
            if userIsSigningUp == true {
                addCompanyHoursEnabledViewController.userIsSigningUp = true
                
                // Save to Coredata
                let filter = NSPredicate(format: "id == %@", "0")
                guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - AddCompanyDaysEnabledViewController"); return }
                coreDataCompanyObject.daysOfTheWeekEnabled = selectedOptionsString
                
                // Save to context
                PersistenceService.saveContext(context: nil)
            }
            
            addCompanyHoursEnabledViewController.company = self.company
            addCompanyHoursEnabledViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addCompanyHoursEnabledViewController, animated: true)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select A Day", body: "Please select at least one day.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
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
