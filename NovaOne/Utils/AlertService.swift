//
//  Alert.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//


// Alert pop ups
import UIKit

class AlertService {
    
    static func alert(for currentViewController: UIViewController?, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        // Displays an alert message with a custom title and message
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: handler)
        
        // Add action button to alert
        alert.addAction(alertAction)
        
        currentViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    func popUp(title: String, body: String, buttonTitle: String, completion: @escaping () -> Void) -> PopUpViewController {
        
        let storyboard = UIStoryboard(name: Defaults.storyboardName, bundle: .main)
        guard let popUpViewController = storyboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.popUp.rawValue) as? PopUpViewController else { return PopUpViewController() }
        
        // Set text values for the pop up view controller
        popUpViewController.popUpTitle = title
        popUpViewController.popUpBody = body
        popUpViewController.popUpActionButtonTitle = buttonTitle
        popUpViewController.popUpButtonActionCompletion = completion
        
        return popUpViewController
    }
    
}
