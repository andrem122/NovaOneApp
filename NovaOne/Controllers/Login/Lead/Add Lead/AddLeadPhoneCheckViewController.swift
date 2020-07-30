//
//  AddLeadPhoneCheckViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadPhoneCheckViewController: AddLeadBaseViewController {
    
    // MARK: Properties
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func yesButtonTapped(_ sender: Any) {
        // Go to addLeadPhoneViewController
        guard let addLeadPhoneViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadPhone.rawValue) as? AddLeadPhoneViewController else { return }
        
        addLeadPhoneViewController.lead = self.lead
        addLeadPhoneViewController.embeddedViewController = self.embeddedViewController

        self.navigationController?.pushViewController(addLeadPhoneViewController, animated: true)
    }
    
    @IBAction func noButtonTapped(_ sender: Any) {
        // Go to renter brand unless this is a customer of type medical worker or 'MW', then just post the data
        
        guard
            let customerType = self.customer?.customerType
        else { return }
        
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            guard let addLeadRenterBrandViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadRenterBrand.rawValue) as? AddLeadRenterBrandViewController else { return }
            
            addLeadRenterBrandViewController.lead = self.lead
            addLeadRenterBrandViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addLeadRenterBrandViewController, animated: true)
        } else {
            
            self.showSpinner(for: self.view, textForLabel: "Adding Lead")
            // Get data for POST parameters
            guard
                let name = self.lead?.name,
                let email = self.lead?.email,
                let companyId = self.lead?.companyId,
                let phoneNumber = self.lead?.phoneNumber,
                let renterBrand = self.lead?.renterBrand,
                let customerEmail = self.customer?.email,
                let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
                let customerUserId = self.customer?.id
            else { return }
            let dateOfInquiry = DateHelper.createString(from: Date(), format: "yyyy-MM-dd HH:mm:ssZ")
            
            let parameters: [String: String] = ["customerUserId": String(customerUserId), "email": customerEmail, "password": customerPassword, "leadName": name, "leadPhoneNumber": phoneNumber, "leadEmail": email, "leadRenterBrand": renterBrand, "dateOfInquiry": dateOfInquiry, "leadCompanyId": String(companyId)]
            
            let httpRequest = HTTPRequests()
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/addLead.php", dataModel: SuccessResponse.self, parameters: parameters) { [weak self] (result) in
                switch result {
                    case .success(let success):
                        // Redirect to success screen
                        
                        let popupStoryboard = UIStoryboard(name: Defaults.StoryBoards.popups.rawValue, bundle: .main)
                        guard let successViewController = popupStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
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
                                guard let leadsTableViewController = self?.embeddedViewController as? LeadsTableViewController else { return }
                                leadsTableViewController.refreshDataOnPullDown()
                            }
                        }
                        self?.present(successViewController, animated: true, completion: nil)
                    case .failure(let error):
                        guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOk, animated: true, completion: nil)
                }
                
                self?.removeSpinner()
            }
            
        }
        
    }
    
}
