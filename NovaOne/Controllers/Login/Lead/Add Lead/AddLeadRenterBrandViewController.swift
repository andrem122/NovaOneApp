//
//  AddLeadRenterBrandViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadRenterBrandViewController: AddLeadBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var picker: UIPickerView!
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    let renterBrands: [String] = [
        "Zillow",
        "Trulia",
        "Realtor",
        "Apartments.com",
        "Hotpads",
        "Craigslist",
        "Move",
        "Other"]
    lazy var selectedRenterBrand: String = {
        guard let renterBrand = self.renterBrands.first else { return "" }
        return renterBrand
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        // Setup the picker view
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func addLeadButtonTapped(_ sender: Any) {
        self.showSpinner(for: self.view, textForLabel: "Adding Lead...")
        
        // Get data for POST parameters
        guard
            let name = self.lead?.name,
            let email = self.lead?.email,
            let companyId = self.lead?.companyId,
            let phoneNumber = self.lead?.phoneNumber,
            let customerEmail = self.customer?.email,
            let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
            let customerUserId = self.customer?.id
            else { return }
        let dateOfInquiry = DateHelper.createString(from: Date(), format: "yyyy-MM-dd HH:mm:ssZ")
        let renterBrand = self.selectedRenterBrand
        
        let parameters: [String: String] = ["customerUserId": String(customerUserId), "email": customerEmail, "password": customerPassword, "leadName": name, "leadPhoneNumber": phoneNumber, "leadEmail": email, "leadRenterBrand": renterBrand, "dateOfInquiry": dateOfInquiry, "leadCompanyId": String(companyId)]
        print(parameters)
        
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/addLead.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
            switch result {
                case .success(let success):
                    // Redirect to success screen
                    
                    self?.removeSpinner()
                    
                    guard let successViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                    successViewController.subtitleText = success.successReason
                    successViewController.titleLabelText = "Lead Added!"
                    successViewController.doneHandler = {
                        [weak self] in
                        // Return to the appointments view and refresh appointments
                        self?.presentingViewController?.dismiss(animated: true, completion: nil)
                        
                        // The embedded view controller in the container view controller is either
                        // the empty view controller or the table view controller
                        if let emptyViewController = self?.embeddedViewController as? EmptyViewController {
                            emptyViewController.refreshButton.sendActions(for: .touchUpInside)
                        } else {
                            print("leads view controller")
                            guard let leadsTableViewController = self?.embeddedViewController as? LeadsTableViewController else { return }
                            leadsTableViewController.refreshDataOnPullDown()
                        }
                    }
                    self?.present(successViewController, animated: true, completion: nil)
                case .failure(let error):
                    self?.removeSpinner()
                    guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOk, animated: true, completion: nil)
            }
        }
    }
    
}

extension AddLeadRenterBrandViewController {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.renterBrands.count
    }
    
    // The value to show for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.renterBrands[row] // Get the string in the genders array and display it for each row in the picker
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRenterBrand = self.renterBrands[row]
    }
    
}
