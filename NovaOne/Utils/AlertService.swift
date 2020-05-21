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
    
    func popUpOk(title: String, body: String) -> PopUpOkViewController {
        // Returns a pop up with an 'OK' button
        
        let storyboard = UIStoryboard(name: Defaults.storyboardName, bundle: .main)
        guard let popUpOkViewController = storyboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.popUpOk.rawValue) as? PopUpOkViewController else { return PopUpOkViewController() }
        
        // Set text values for the pop up view controller
        popUpOkViewController.popUpTitle = title
        popUpOkViewController.popUpBody = body
        
        return popUpOkViewController
    }
    
    func popUp(title: String, body: String, buttonTitle: String, actionHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> PopUpActionViewController {
        // Returns a pop up with a cancel and action button
        
        let storyboard = UIStoryboard(name: Defaults.storyboardName, bundle: .main)
        guard let popUpViewController = storyboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.popUp.rawValue) as? PopUpActionViewController else { return PopUpActionViewController() }
        
        // Set text values for the pop up view controller
        popUpViewController.popUpTitle = title
        popUpViewController.popUpBody = body
        popUpViewController.popUpActionButtonTitle = buttonTitle
        popUpViewController.actionHandler = actionHandler
        popUpViewController.cancelHandler = cancelHandler
        
        return popUpViewController
    }
    
}
