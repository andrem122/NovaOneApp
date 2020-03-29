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
    var hoursOfTheDayAM: [EnabledOption] = [
        EnabledOption(option: "12:00", selected: false),
        EnabledOption(option: "1:00", selected: false),
        EnabledOption(option: "2:00", selected: false),
        EnabledOption(option: "3:00", selected: false),
        EnabledOption(option: "4:00", selected: false),
        EnabledOption(option: "5:00", selected: false),
        EnabledOption(option: "6:00", selected: false),
        EnabledOption(option: "7:00", selected: false),
        EnabledOption(option: "8:00", selected: false),
        EnabledOption(option: "9:00", selected: false),
        EnabledOption(option: "10:00", selected: false),
        EnabledOption(option: "11:00", selected: false),
    ]
    
    var hoursOfTheDayPM: [EnabledOption] = [
        EnabledOption(option: "12:00", selected: false),
        EnabledOption(option: "1:00", selected: false),
        EnabledOption(option: "2:00", selected: false),
        EnabledOption(option: "3:00", selected: false),
        EnabledOption(option: "4:00", selected: false),
        EnabledOption(option: "5:00", selected: false),
        EnabledOption(option: "6:00", selected: false),
        EnabledOption(option: "7:00", selected: false),
        EnabledOption(option: "8:00", selected: false),
        EnabledOption(option: "9:00", selected: false),
        EnabledOption(option: "10:00", selected: false),
        EnabledOption(option: "11:00", selected: false),
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
             
             // If the substring is PM, get an EnabledOption item from the PM array
             // else get an EnabledOption item from the AM array
             if hour.contains(substring) {
                 for (index, enabledOption) in self.hoursOfTheDayPM.enumerated() {
                     if enabledOption.option == hourWithoutAMOrPM {
                         self.hoursOfTheDayPM[index].selected = true
                     }
                 }
             } else {
                 for (index, enabledOption) in self.hoursOfTheDayAM.enumerated() {
                     if enabledOption.option == hourWithoutAMOrPM {
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
        
        switch indexPath.section {
            case 0:
                let hour = self.hoursOfTheDayAM[indexPath.row] // Get the hour of the day
                // If the option was selected, set the check mark image to be visible
                // when the cell is pulled out of the quene and reused
                if hour.selected {
                    cell.checkMarkImage.isHidden = false
                } else {
                    cell.checkMarkImage.isHidden = true
                }
                
                cell.setup(option: hour.option)
            case 1:
                let hour = self.hoursOfTheDayPM[indexPath.row] // Get the hour of the day
                // If the option was selected, set the check mark image to be visible
                // when the cell is pulled out of the quene and reused
                if hour.selected {
                    cell.checkMarkImage.isHidden = false
                } else {
                    cell.checkMarkImage.isHidden = true
                }
                
                cell.setup(option: hour.option)
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
