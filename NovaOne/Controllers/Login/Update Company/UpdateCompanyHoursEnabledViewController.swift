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
        self.setup()
        self.setHours()
    }
    
    func setup() {
        // Set delegate and datasource for table view
        self.updateCompanyHoursEnabledTableView.delegate = self
        self.updateCompanyHoursEnabledTableView.dataSource = self
    }
    
    func setHours() {
        // Sets the check marks on each cell to visible based on what hours
        // the user has selected perviously
        
         guard
             let customer = PersistenceService.fetchCustomerEntity(),
             let hoursOfTheDayEnabledString = customer.hoursOfTheDayEnabled
         else { return }
         
         // Convert hours of the day enabled string into array of integers
         var hoursOfTheDayEnabled: [String] = hoursOfTheDayEnabledString.components(separatedBy: ",")
         
         hoursOfTheDayEnabled = self.convertToTwelveHourFormat(hours: hoursOfTheDayEnabled)
         
         for hour in hoursOfTheDayEnabled {
             // Get the AM/PM part of the hour string
             let substring = "PM"
             guard let hourWithoutAMOrPM = hour.components(separatedBy: " ").first else { return } // 12:00
             
             // If the substring is PM, get an EnableOption item from the PM array
             // else get an EnableOption item from the AM array
             if hour.contains(substring) {
                 for (index, enableOption) in self.hoursOfTheDayPM.enumerated() {
                     if enableOption.option == hourWithoutAMOrPM {
                         self.hoursOfTheDayPM[index].selected = true
                     }
                 }
             } else {
                 for (index, enableOption) in self.hoursOfTheDayAM.enumerated() {
                     if enableOption.option == hourWithoutAMOrPM {
                         self.hoursOfTheDayAM[index].selected = true
                     }
                 }
             }
         }
    }
    
    func convertToTwelveHourFormat(hours: [String]) -> [String] {
        // Converts strings of time from 24 hour format to 12 hour format
        
        let dateFormatter = DateFormatter()
        var twelveHourArray: [String] = []
        for hour in hours {
            dateFormatter.dateFormat = "H"
            guard let date24 = dateFormatter.date(from: hour) else { return [""] }
            
            dateFormatter.dateFormat = "h:mm a"
            let date12 = dateFormatter.string(from: date24)
            twelveHourArray.append(date12)
        }
        
        return twelveHourArray
        
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Remove the modal popup view on touch of the cancel 'x' button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension UpdateCompanyHoursEnabledViewController {
    
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
