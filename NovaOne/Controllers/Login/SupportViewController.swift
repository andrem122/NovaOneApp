//
//  SupportViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import MessageUI

class SupportViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var supportTextView: NovaOneTextView!
    @IBOutlet weak var submitButton: NovaOneButton!
    let alertService = AlertService()
    let customer: Customer? = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.supportTextView.becomeFirstResponder()
    }
    
    func setupTextView() {
        self.supportTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
    }
    
    // MARK: Actions
    @IBAction func submitButtonTapped(_ sender: Any) {
        // Send email if there is text in the text view
        
        self.showSpinner(for: self.view, textForLabel: "Sending message...")
        let customerMessage = self.supportTextView.text != nil ? self.supportTextView.text! : ""
        if customerMessage.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "No Message", body: "Please type in a message.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            
            // Make POST request to support.php
            guard
                let email = self.customer?.email,
                let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
            else { return }
            let parameters: [String: Any] = ["email": email, "password": password, "customerMessage": customerMessage]
            let httpRequest = HTTPRequests()
            
            httpRequest.request(url: Defaults.Urls.api.rawValue + "/support.php", dataModel: SuccessResponse.self, parameters: parameters) {
                [weak self] (result) in
                switch result {
                    case .success(_):
                        // Go to success view controller
                        guard let successViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                        successViewController.titleLabelText = "Message Sent!"
                        successViewController.subtitleText = "Your message was successfully sent to support. We will get back to you shortly."
                        
                        self?.present(successViewController, animated: true, completion: nil)
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        guard let popUpOkViewController = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                        self?.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                self?.removeSpinner()
            }
            
        }
    }
}
