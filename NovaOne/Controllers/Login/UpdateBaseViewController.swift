//
//  UpdateBaseViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/20/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class UpdateBaseViewController: UIViewController {
    
    // MARK: Properties
    var detailViewController: NovaOneObjectDetail?
    var updateObject: NSManagedObject?
    let alertService = AlertService()
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateObject<T: NSManagedObject>(for tableName: String,
                                          at columns: [String: String],
                                          endpoint: String,
                                          objectId: Int,
                                          objectType: T.Type,
                                          updateClosure: @escaping (T) -> Void,
                                          successSubtitle: String,
                                          successDoneHandler: @escaping () -> Void) {
        // Update the object's value in the database
        
        self.showSpinner(for: self.view, textForLabel: "Updating...")
        
        guard
            let customerEmail = self.customer?.email,
            let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        
        // Convert dictionary to json string
        guard let jsonData = try? JSONSerialization.data(withJSONObject: columns) else { print("Unable to encode columns to JSON data object"); return }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { print("unable to get string from json data"); return }
        
        let parameters: [String: Any] = ["email": customerEmail, "password": customerPassword, "tableName": tableName, "columns": jsonString as Any, "objectId": objectId]
        let httpRequest = HTTPRequests()
        httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint, dataModel: SuccessResponse.self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(_):
                    
                    // Update core data object
                    guard let updateObject = self?.updateObject as? T else { print("could not convert to company");return }
                    updateClosure(updateObject)
                    PersistenceService.saveContext()
                    
                    // Show success view controller
                    guard let successViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                    
                    successViewController.titleLabelText = "Update Complete!"
                    successViewController.subtitleText = successSubtitle
                    successViewController.doneHandler = successDoneHandler
                    
                    self?.present(successViewController, animated: true, completion: nil)
                    
                    // Remove the update view controller
                    self?.navigationController?.popViewController(animated: true)
                
                case .failure(let error):
                    guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                    self?.present(popUpOkViewController, animated: true, completion: nil)
                
            }
            
        }
    }

}
