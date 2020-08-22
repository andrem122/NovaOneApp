//
//  AddCompanyAllowSameDayAppointmentsViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyAllowSameDayAppointmentsViewController: AddCompanyBaseViewController {
    
    // MARK: Properties
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue
        
        let userInfo = [AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func saveToCoreData(allowSameDayAppointments: Bool) {
        // Save to core data for user to pickup where they left off if they leave the app
        // Get existing core data object and update it
        let filter = NSPredicate(format: "id == %@", "0")
        guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - AddCompanyAllowSameDayAppointmentsViewController"); return }
        coreDataCompanyObject.allowSameDayAppointments = allowSameDayAppointments
        
        // Save to context
        PersistenceService.saveContext()
    }
    
    func goToAddCompanyDaysEnabled() -> Void {
        guard
            let addCompanyDaysEnabledViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue) as? AddCompanyDaysEnabledViewController
        else { return }
        
        addCompanyDaysEnabledViewController.company = self.company
        addCompanyDaysEnabledViewController.embeddedViewController = self.embeddedViewController
        if self.userIsSigningUp == true {
            addCompanyDaysEnabledViewController.userIsSigningUp = true
        }
        
        self.navigationController?.pushViewController(addCompanyDaysEnabledViewController, animated: true)
    }
    
    // MARK: Actions
    @IBAction func yesButtonTapped(_ sender: Any) {
        self.company?.allowSameDayAppointments = true
        
        self.saveToCoreData(allowSameDayAppointments: true)
        goToAddCompanyDaysEnabled()
    }
    
    
    @IBAction func noButtonTapped(_ sender: Any) {
        self.company?.allowSameDayAppointments = false
        self.saveToCoreData(allowSameDayAppointments: false)
        goToAddCompanyDaysEnabled()
    }
    
}
