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
            addAppointmentUnitTypeViewController.appointmentsTableViewController = self.appointmentsTableViewController
            
            self.navigationController?.pushViewController(addAppointmentUnitTypeViewController, animated: true)
            
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            // Navigate to add appointment email view controller
            guard let addAppointmentEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentEmail.rawValue) as? AddAppointmentEmailViewController else { return }
            
            addAppointmentEmailViewController.appointment = self.appointment
            
            self.navigationController?.pushViewController(addAppointmentEmailViewController, animated: true)
            
        }
        
    }

}
