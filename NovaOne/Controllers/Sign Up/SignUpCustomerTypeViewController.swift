//
//  SignUpCustomerTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpCustomerTypeViewController: BaseSignUpViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var pickerView: UIPickerView!
    let customerTypes = ["Property Manager", "Medical Worker"]
    var customerType: String = "PM"
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue
        
        let userInfo = [AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPickerView()
    }
    
    func setupPickerView() {
        // Sets up the picker view
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
    }
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let signUpCompanyNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue) as? SignUpCompanyNameViewController else { return }
        
        self.customer?.customerType = self.customerType
        signUpCompanyNameViewController.customer = self.customer
        
        self.navigationController?.pushViewController(signUpCompanyNameViewController, animated: true)
    }
}

extension SignUpCustomerTypeViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.customerTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.customerTypes[row] // Get the string in the array and display it for each row in the picker
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.customerType = self.customerTypes[row] == "Property Manager" ? "PM" : "MW"
    }
}
