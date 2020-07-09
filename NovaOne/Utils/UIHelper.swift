//
//  UIHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/5/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

// A class of commonly used functions used for interacting with the user interface
class UIHelper {
    
    static func setupNavigationBarStyle(for navigationController: UINavigationController?) {
        // Sets the styles for the navigation bar
        
        // Set styles for navigation bar
        guard let unwrappedNavigationController = navigationController else { return }
        unwrappedNavigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        unwrappedNavigationController.navigationBar.shadowImage = UIImage()
    }
    
    // Toggles a button between enabled and disabled states based on text field values
    static func toggle(button: UIButton, textField: UITextField?, enabledColor: UIColor, disabledColor: UIColor, borderedButton: Bool?, closure: (() -> Bool)?) {
        
        // If we decide to use the closure (more than one text field we want to check the value of before disabling the button)
        if let unwrappedClosure = closure {
            
            // Closure will return a boolean and if it is false, the button will be disabled else it will be enabled
            if unwrappedClosure() == false {
                
                // Disable the button
                button.isEnabled = false
                
                if borderedButton == true {
                    button.layer.borderColor = disabledColor.cgColor
                } else {
                    button.backgroundColor = disabledColor
                    button.layer.borderColor = disabledColor.cgColor
                }
                
            } else {
                
                // Enable button if true is returned
                button.isEnabled = true
                
                if borderedButton == true {
                    button.layer.borderColor = enabledColor.cgColor
                } else {
                    button.backgroundColor = enabledColor
                    button.layer.borderColor = enabledColor.cgColor
                }
                
            }
            
        } else { // One text field we are checking the value of to disable the button
            
            guard
                let textField = textField,
                let text = textField.text
            else { return }
            
            if text.isEmpty {
                
                button.isEnabled = false
                
                if borderedButton == true {
                    button.layer.borderColor = disabledColor.cgColor
                } else {
                    button.backgroundColor = disabledColor
                    button.layer.borderColor = disabledColor.cgColor
                }
                
            } else {
                
                button.isEnabled = true
                
                if borderedButton == true {
                    button.layer.borderColor = enabledColor.cgColor
                } else {
                    button.backgroundColor = enabledColor
                    button.layer.borderColor = enabledColor.cgColor
                }
                
            }
            
        }

    }
    
    static func disable(button: UIButton, disabledColor: UIColor, borderedButton: Bool?) {
        // Disables a button
        button.isEnabled = false
        if borderedButton == true {
            button.layer.borderColor = disabledColor.cgColor
        } else {
            button.backgroundColor = disabledColor
        }
        
    }
    
    static func enable(button: UIButton, enabledColor: UIColor, borderedButton: Bool?) {
        // Enables a button
        button.isEnabled = true
        if borderedButton == true {
            button.layer.borderColor = enabledColor.cgColor
        } else {
            button.backgroundColor = enabledColor
        }
        
    }
    
    static func showEmptyStateContainerViewController(for currentViewController: UIViewController?, containerView: UIView, title: String, addObjectButtonTitle: String, completion: ((EmptyViewController) -> Void)?) {
        // Shows the empty state view controller for a container view
        
        let popupStoryboard = UIStoryboard(name: Defaults.StoryBoards.popups.rawValue, bundle: .main)
        if let emptyViewController = popupStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.empty.rawValue) as? EmptyViewController {
            
            emptyViewController.titleLabelText = title
            emptyViewController.addObjectButtonTitle = addObjectButtonTitle
            
            currentViewController?.addChild(emptyViewController)
            emptyViewController.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(emptyViewController.view)
            
            // Set constraints for embedded view so it shows correctly
            NSLayoutConstraint.activate([
                emptyViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                emptyViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                emptyViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                emptyViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            emptyViewController.didMove(toParent: currentViewController)
            
            // Plug the empty container view controller into the completion function
            if let completion = completion {
                completion(emptyViewController)
            }
            
        }
    }
    
    static func showSuccessContainer<T: UIViewController>(for currentViewController: UIViewController?, successContainerViewIdentifier: String, containerView: UIView, objectType: T.Type, completion: ((UIViewController) -> Void)?) {
        // Shows the table with items for the container view
        
        guard let successContainerViewController = currentViewController?.storyboard?.instantiateViewController(identifier: successContainerViewIdentifier) as? T else { return }

        // Embed appointments view controller into container view so it will show
        currentViewController?.addChild(successContainerViewController)
        successContainerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(successContainerViewController.view)
        
        // Set constraints for embedded view so it shows correctly
        NSLayoutConstraint.activate([
            successContainerViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            successContainerViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            successContainerViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            successContainerViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        successContainerViewController.didMove(toParent: currentViewController)
        
        // Plug the success container view controller into the completion function
        guard let completion = completion else { return }
        completion(successContainerViewController)
    }
    
}
