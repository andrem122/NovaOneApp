//
//  AddAppointmentTimeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentTimeViewController: AddAppointmentBaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var appointmentTimePicker: UIDatePicker!
    var hoursEnabled: [Int]?
    var daysEnabled: [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTimePicker()
    }
    
    func setupTimePicker() {
        // Sets up the time picker
        
        // Get company to get hours enabled and days enabled
        guard let companyId = self.appointment?.companyId else { return }
        let predicate = NSPredicate(format: "id = %@", String(companyId))
        
        // Set the minimun allowed date (starting date) for the datetime picker
        guard
            let company = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first
        else { return }
        
        self.daysEnabled = company.daysOfTheWeekEnabled?.components(separatedBy: ",").map {
            guard let integer = Int($0) else { return 0 }
            return integer
        }.sorted()
        self.hoursEnabled = company.hoursOfTheDayEnabled?.components(separatedBy: ",").map {
            guard let integer = Int($0) else { return 0 }
            return integer
        }.sorted()
        
        // Get the next available week day and hour
        let now = Date()
        var nowDateComponents = Calendar.current.dateComponents([.calendar, .day, .era, .hour, .minute, .month, .nanosecond, .quarter, .second, .timeZone, .weekday, .year, .weekOfMonth], from: now)
        
        guard
            let nowWeekday = nowDateComponents.weekday,
            let nowHour = nowDateComponents.hour,
            let closestWeekDayIndex = self.daysEnabled?.firstIndex(where: {$0 >= (nowWeekday - 1)}),
            let closestHourIndex = self.hoursEnabled?.firstIndex(where: { $0 >= nowHour }),
            let closestWeekDay = self.daysEnabled?[closestWeekDayIndex],
            let closestHour = self.hoursEnabled?[closestHourIndex]
        else { return }
        
        // Create date from closest date components
        nowDateComponents.hour = closestHour
        nowDateComponents.weekday = closestWeekDay
        
        let nextAvailableDate = Calendar.current.date(from: nowDateComponents)
        
        self.appointmentTimePicker.minimumDate = nextAvailableDate
        self.appointmentTimePicker.minuteInterval = 30
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        // Get hour and day selected from the datetime picker to see if day and hour selected is available
        let dateSelected = self.appointmentTimePicker.date
        let selectedweekDay = Calendar.current.component(.weekday, from: dateSelected) - 1
        let selectedhour = Calendar.current.component(.hour, from: dateSelected)
        print("WEEK DAY: \(selectedweekDay), HOUR: \(selectedhour)")
        
        guard
            let hoursEnabled = self.hoursEnabled,
            let daysEnabled = self.daysEnabled
        else { return }
        
        // If the day or hour selected is NOT in the days or hours enabled array, pop up an error
        let popUpOkViewController = self.alertService.popUpOk(title: "Unavailable Day", body: "The day selected for this company is unavailable. Please choose a different day.")
        if !daysEnabled.contains(selectedweekDay) {
            self.present(popUpOkViewController, animated: true, completion: nil)
            return
        } else if !hoursEnabled.contains(selectedhour) {
            popUpOkViewController.popUpTitle = "Unavailable Hour"
            popUpOkViewController.popUpBody = "The hour selected for this company is unavailable. Please choose a different hour."
            self.present(popUpOkViewController, animated: true, completion: nil)
            return
        }

        // Get customer object to get customer type
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerType = customer.customerType
        else { return }
        
        // Get appointment time from date picker
        let appointmentTime = DateHelper.createString(from: self.appointmentTimePicker.date, format: "MM/dd/yyyy hh:mm a")
        self.appointment?.time = appointmentTime
        
        // Show the next view controller based on the customer type
        // For property managers
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            // Navigate to add appointment unit type view controller
            guard let addAppointmentUnitTypeViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentUnitType.rawValue) as? AddAppointmentUnitTypeViewController else { return }
            addAppointmentUnitTypeViewController.appointment = self.appointment
            self.navigationController?.pushViewController(addAppointmentUnitTypeViewController, animated: true)
            
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            // Navigate to add appointment email view controller
            guard let addAppointmentEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue) as? AddAppointmentEmailViewController else { return }
            addAppointmentEmailViewController.appointment = self.appointment
            self.navigationController?.pushViewController(addAppointmentEmailViewController, animated: true)
            
        }
        
    }

}
