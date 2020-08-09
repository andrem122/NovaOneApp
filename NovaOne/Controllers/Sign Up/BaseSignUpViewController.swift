//
//  BaseSignUpViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class BaseSignUpViewController: UIViewController {
    
    // MARK: Properties
    let alertService = AlertService()
    var customer: CustomerModel?
    var company: CompanyModel?
    var restoreText: String? // Text for state restoration
    var restoreContinueButtonState: Bool? // For state restoration

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addKeyboardObservers()
    }
    
    func continueFrom(activity: NSUserActivity) {
        // Restore the view controller to its previous state using the activity object plugged in from scene delegate method scene(_:willConnectTo:options:)
        let restoreText = activity.userInfo?[AppState.UserActivityKeys.signup.rawValue] as? String
        let continueButtonIsEnabled = activity.userInfo?[AppState.UserActivityKeys.signupButtonEnabled.rawValue] as? Bool
        self.restoreText = restoreText
        self.restoreContinueButtonState = continueButtonIsEnabled
    }
    
    func restore(textField: UITextField, continueButton: UIButton, coreDataEntity: NSManagedObject.Type, attributeClosure: (NSManagedObject) -> String) {
        // Restores the text and button state for the sign up view controller
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            textField.text = self.restoreText
            
            // Restore button state
            guard let continueButtonState = self.restoreContinueButtonState else { return }
            if continueButtonState == true {
                UIHelper.enable(button: continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            } else {
                UIHelper.disable(button: continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            }
            
        } else {
            // Get data from coredata if it is available and fill in the field if no state restoration text exists
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataObject = PersistenceService.fetchEntity(coreDataEntity, filter: filter, sort: nil).first else {
                UIHelper.disable(button: continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
                print("could not get coredata company object - BaseSignUpViewController")
                return
            }
            
            // Give the user access to the core data object to allow them to get the attribute from the core data object and return it for updating
            let attributeValue = attributeClosure(coreDataObject)
            textField.text = attributeValue
            
            // Enable the continue button
            if attributeValue.isEmpty {
                UIHelper.disable(button: continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            } else {
                UIHelper.enable(button: continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            }
        }
    }
    
    func setupNavigationBar() {
        // Sets up the navigation bar
        // Set styles for navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = Defaults.novaOneColor
    }

}
