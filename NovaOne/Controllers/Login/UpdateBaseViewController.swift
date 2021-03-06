//
//  UpdateBaseViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/20/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class UpdateBaseViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    var previousViewController: UIViewController?
    var updateCoreDataObjectId: Int32? // Id of the core data object we want to update
    let alertService = AlertService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait) // Lock orientation to potrait
    }
    
    func updateObject<T: NSManagedObject>(for tableName: String,
                                          at columns: [String: Any],
                                          endpoint: String,
                                          objectId: Int,
                                          objectType: T.Type,
                                          updateClosure: ((T) -> Void)?,
                                          filterFormat: String,
                                          successSubtitle: String?,
                                          currentAuthenticationEmail: String?,
                                          successDoneHandler: (() -> Void)?,
                                          completion: (() -> Void)?) {
        
        // Get core data object for updating if updateClosure is not nil
        if let unwrappedUpdateClosure = updateClosure {
            let filter = NSPredicate(format: filterFormat, String(objectId))
            guard let updateObject = PersistenceService.fetchEntity(objectType, filter: filter, sort: nil).first else { print("could not get update object - UpdateBaseViewController"); return }
            
            unwrappedUpdateClosure(updateObject)
            PersistenceService.saveContext(context: nil)
        }
        
        // Show success view controller if success sub title is not nil
        if let subtitle = successSubtitle {
            
            let popupStoryboard = UIStoryboard(name: Defaults.StoryBoards.popups.rawValue, bundle: .main)
            guard let successViewController = popupStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { print("could not get success view controller - UpdateBaseViewController"); return }
            
            successViewController.titleLabelText = "Update Complete!"
            successViewController.subtitleText = subtitle
            successViewController.doneHandler = successDoneHandler
            
            guard let previousViewController = self.previousViewController else { print("could not get previous view controller - UpdateBaseViewController"); return }
            
            // Dismiss update view controller and present success view controller after
            if let objectDetailViewController = previousViewController as? NovaOneObjectDetail {
                // For detail view controllers
                guard let tableViewController = objectDetailViewController.previousViewController else { return }
                
                // Remove update view controller and present success view controller
                previousViewController.dismiss(animated: false, completion: {
                    [weak self] in
                    // Do not have to remove spinner view after dismissing update view because when the update
                    // view is dismissed it removes the spinner view
                    
                    guard let isCollapsed = tableViewController.splitViewController?.isCollapsed else { print("could not get split view controller is collapsed porperty - UpdateBaseViewController"); return }
                    guard let sizeClass = self?.getSizeClass() else { return }
                    
                    if isCollapsed == false && sizeClass == (.compact, .regular) {
                        // For iPhones that click an update cell in the detail view controller
                        // and are rotated for the update view controller
                        // and are in the size class that has split views enabled
                        self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else if isCollapsed == false {
                        guard let novaOneTableView = tableViewController as? NovaOneTableView else { return }
                        novaOneTableView.didSetFirstItem = false // Set equal to false so the table view controller will set the first item in the detail view again with fresh properties, so we don't get update errors
                        novaOneTableView.setFirstItemForDetailView()
                    } else {
                        previousViewController.present(successViewController, animated: true, completion: nil)
                    }
                    
                })
            } else {
                // For updates coming from the account table view controller
                self.present(successViewController, animated: true, completion: {
                    previousViewController.navigationController?.popViewController(animated: true)
                })
            }
            
        }
        
        // Update the object's value in the database
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let coreDataEmail = customer.email,
            let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { print("could  not get customer email and password - UpdateBaseViewController"); return }
        
        // Get email from core data if we are NOT updating the user's email else
        // use the email string in the parameter 'currentAuthenticationEmail'
        let customerEmail = currentAuthenticationEmail != nil ? currentAuthenticationEmail! : coreDataEmail
        
        // Convert dictionary to json string
        guard let jsonData = try? JSONSerialization.data(withJSONObject: columns) else { print("Unable to encode columns to JSON data object"); return }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { print("unable to get string from json data"); return }
        
        let parameters: [String: Any] = ["email": customerEmail, "password": customerPassword, "tableName": tableName, "columns": jsonString as Any, "objectId": objectId]
        //print("Update Parameters: \(parameters)")
        
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint, dataModel: SuccessResponse.self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let success):
                    print("Object successfully updated in database: \(success.successReason)")
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                
            }
            
            // Run completion function
            guard let unwrappedCompletion = completion else { return }
            unwrappedCompletion()
            
        }
        
    }
    
    func setupUpdateButton(button: UIButton) {
        // Setup the update button
        UIHelper.disable(button: button, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
    }
    
    func setupTextField(textField: UITextField) {
        // Setup the text field
        textField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        // Reset orientation
        AppUtility.lockOrientation(.all)
    }
    
}
