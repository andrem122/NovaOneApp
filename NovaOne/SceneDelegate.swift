//
//  SceneDelegate.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appState = AppState()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("Scene Delegate willConnectTo")
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Get user logged in state
        let isLoggedIn = UserDefaults.standard.bool(forKey: Defaults.UserDefaults.isLoggedIn.rawValue)
        
        // Handle when the user clicks on the notification
        if let notificationResponse = connectionOptions.notificationResponse, isLoggedIn == true {
            
            
            let content = notificationResponse.notification.request.content.userInfo
            guard
                let selectIndex = content["selectIndex"] as? Int, // The index to select on the tab bar controller when the user opens the app
                let newLeadCount = content["newLeadCount"] as? Int,
                let newAppointmentCount = content["newAppointmentCount"] as? Int
            else {
                return
            }
            
            // If we get a new appointment (indicated by selectIndex), then notification count is equal to new appointment count
            // else it will be equal to newLeadCount
            let notificationCount = selectIndex == 1 ? newAppointmentCount : newLeadCount
            
            // Get the window object to show the view to restore
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)
            
            // Get storyboards
            let mainStoryboard = UIStoryboard(name: Defaults.StoryBoards.main.rawValue, bundle: .main)
            
            // Get view controller and present
            guard
                let startViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController
            else {
                print("could not get startViewController - SceneDelegate")
                return
            }
            
            // If user is logged in, show the container view controller on a specific tab
            guard let containerViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.container.rawValue) as? ContainerViewController else { print("could not get container view controller - SceneDelegate")
                return
            }
            
            containerViewController.homeTabBarSelectIndex = selectIndex
            containerViewController.homeTabBarNotificationCount = notificationCount
            
            // Set root controller for the window
            self.window?.rootViewController = startViewController
            
            // Make the window the key window and visible to the user after setting it up above
            self.window?.makeKeyAndVisible()
            containerViewController.modalPresentationStyle = .fullScreen

            startViewController.present(containerViewController, animated: true, completion: nil)
            
        }
        
        // If we have a NSUserActivity object from a previous opening of the app
        if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity, isLoggedIn == false {
            
            // Get the window object to show the view to restore
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)

            // Detect what view controller we left on when the user closed the app
            guard let viewControllerIdentifier = activity.userInfo?[AppState.activityViewControllerIdentifierKey] as? String else { print("could not get view controller identifier"); return }
            
            // For the activity of signing up users
            if activity.activityType == AppState.UserActivities.signup.rawValue {
                
                // Get storyboards
                let mainStoryboard = UIStoryboard(name: Defaults.StoryBoards.main.rawValue, bundle: .main)
                let signupStoryboard = UIStoryboard(name: Defaults.StoryBoards.signup.rawValue, bundle: .main)
                let addCompanyStoryboard = UIStoryboard(name: Defaults.StoryBoards.addCompany.rawValue, bundle: .main)
                guard
                    let startViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController
                else { return }
                
                // Set root controller for the window
                self.window?.rootViewController = startViewController
                
                // Make the window the key window and visible to the user after setting it up above
                window?.makeKeyAndVisible()
                
                // Get view controllers to recreate navigation sign up stack
                // Customer
                guard
                    let signupEmailViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpEmail.rawValue) as? SignUpEmailViewController
                else { return }
                
                guard
                    let signupPasswordViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpPassword.rawValue) as? SignUpPasswordViewController
                else { return }
                
                guard
                    let signupNameViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpName.rawValue) as? SignUpNameViewController
                else { return }
                
                guard
                    let signupPhoneViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpPhone.rawValue) as? SignUpPhoneViewController
                else { return }
                
                guard
                    let signupCustomerTypeViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue) as? SignUpCustomerTypeViewController
                else { return }
                
                // Company
                guard
                    let signupCompanyNameViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue) as? SignUpCompanyNameViewController
                else { return }
                
                guard
                    let signupCompanyAddressViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue) as? SignUpCompanyAddressViewController
                else { return }
                
                guard
                    let signupCompanyEmailViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue) as? SignUpCompanyEmailViewController
                else { return }
                
                guard
                    let signupCompanyPhoneViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue) as? SignUpCompanyPhoneViewController
                else { return }
                
                guard
                    let addCompanyAllowSameDayAppointmentsViewController = addCompanyStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue) as? AddCompanyAllowSameDayAppointmentsViewController
                else { return }
            
                guard
                    let addCompanyDaysEnabledViewController = addCompanyStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue) as? AddCompanyDaysEnabledViewController
                else { return }
                
                guard
                    let addCompanyHoursEnabledViewController = addCompanyStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.addCompanyHoursEnabled.rawValue) as? AddCompanyHoursEnabledViewController
                else { return }
                
                // Setup sign up navigation controller stack
                let signupNavigationController = UINavigationController(rootViewController: signupEmailViewController)
                signupNavigationController.modalPresentationStyle = .fullScreen
                signupNavigationController.viewControllers = [
                    signupEmailViewController,
                    signupPasswordViewController,
                    signupNameViewController,
                    signupPhoneViewController,
                    signupCustomerTypeViewController,
                    signupCompanyNameViewController,
                    signupCompanyAddressViewController,
                    signupCompanyEmailViewController,
                    signupCompanyPhoneViewController,
                    addCompanyAllowSameDayAppointmentsViewController,
                    addCompanyDaysEnabledViewController,
                    addCompanyHoursEnabledViewController]
                
                // Setup transparent navigation bar for sign up stack
                signupEmailViewController.setupNavigationBar()
                
                // For the sign up email view controller
                if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpEmail.rawValue {
                    // Continue from where the user left off
                    signupEmailViewController.continueFrom(activity: activity)
                    
                    // Present email view controller from navigation stack
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupEmailViewController, animated: true)
                    
                } else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpPassword.rawValue {
                    // For the sign up password view controller
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupPasswordViewController, animated: true)
                    
                } else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpName.rawValue {
                    // For the sign up name view controller
                    // Continue from where the user left off
                    signupNameViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupNameViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpPhone.rawValue {
                    // For the sign up phone view controller
                    // Continue from where the user left off
                    signupPhoneViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupPhoneViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpCustomerType.rawValue {
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupCustomerTypeViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpCompanyName.rawValue {
                    
                    signupCompanyNameViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupCompanyNameViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue {
                    
                    signupCompanyAddressViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupCompanyAddressViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue {
                    
                    signupCompanyEmailViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupCompanyEmailViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.signUpCompanyPhone.rawValue {
                    
                    signupCompanyPhoneViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupCompanyPhoneViewController, animated: true)
                    
                }
                    
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.addCompanyAllowSameDayAppointments.rawValue {
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(addCompanyAllowSameDayAppointmentsViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.addCompanyDaysEnabled.rawValue {
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(addCompanyDaysEnabledViewController, animated: true)
                    
                }
                
                else if viewControllerIdentifier == Defaults.ViewControllerIdentifiers.addCompanyHoursEnabled.rawValue {
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    addCompanyHoursEnabledViewController.userIsSigningUp = true
                    signupNavigationController.popToViewController(addCompanyHoursEnabledViewController, animated: true)
                    
                }
            }
            
        }
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        // Check if the leads table view controller is visible when closing/stopping the app
        print("Scene Delegate sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        print("Scene Delegate stateRestorationActivity")
        
        let topController = self.getTopViewController()
        
        // For the activity of signing up users
        // Check the first view controller and see if it is sign up email view controller, if it is then we are on the sign up navigation stack
        if let signupNavigationController = topController as? UINavigationController,
            (signupNavigationController.viewControllers.first as? SignUpEmailViewController) != nil {
            
            // Signup email view controller
            if let signupEmailViewController = signupNavigationController.topViewController as? SignUpEmailViewController {
                print("SignUpEmailViewController stateRestorationActivity")
                return signupEmailViewController.continuationActivity
            }
            // Signup password view controller
            else if let signupPasswordViewController = signupNavigationController.topViewController as? SignUpPasswordViewController {
                print("SignUpPasswordViewController stateRestorationActivity")
                return signupPasswordViewController.continuationActivity
            }
            
            // Signup name view controller
            else if let signupNameViewController = signupNavigationController.topViewController as? SignUpNameViewController {
                print("SignUpNameViewController stateRestorationActivity")
                return signupNameViewController.continuationActivity
            }
            
            // Signup phone view controller
            else if let signupPhoneViewController = signupNavigationController.topViewController as? SignUpPhoneViewController {
                print("SignUpPhoneViewController stateRestorationActivity")
                return signupPhoneViewController.continuationActivity
            }
            
            // Signup customer type view controller
            else if let signupCustomerTypeViewController = signupNavigationController.topViewController as? SignUpCustomerTypeViewController {
                print("SignUpCustomerTypeViewController stateRestorationActivity")
                return signupCustomerTypeViewController.continuationActivity
            }
            
            // Signup company name view controller
            else if let signupCompanyNameViewController = signupNavigationController.topViewController as? SignUpCompanyNameViewController {
                print("SignUpCompanyNameViewController stateRestorationActivity")
                return signupCompanyNameViewController.continuationActivity
            }
            
            // Signup company address view controller
            else if let signupCompanyAddressViewController = signupNavigationController.topViewController as? SignUpCompanyAddressViewController {
                print("SignUpCompanyAddressViewController stateRestorationActivity")
                return signupCompanyAddressViewController.continuationActivity
            }
            
            // Signup company email view controller
            else if let signupCompanyEmailViewController = signupNavigationController.topViewController as? SignUpCompanyEmailViewController {
                print("SignUpCompanyEmailViewController stateRestorationActivity")
                return signupCompanyEmailViewController.continuationActivity
            }
            
            // Signup company phone view controller
            else if let signupCompanyPhoneViewController = signupNavigationController.topViewController as? SignUpCompanyPhoneViewController {
                print("SignUpCompanyPhoneViewController stateRestorationActivity")
                return signupCompanyPhoneViewController.continuationActivity
            }
                
            // Add company allow same day appointments
            else if let addCompanyAllowSameDayAppointmentsViewController = signupNavigationController.topViewController as? AddCompanyAllowSameDayAppointmentsViewController {
                print("AddCompanyAllowSameDayAppointmentsViewController stateRestorationActivity")
                return addCompanyAllowSameDayAppointmentsViewController.continuationActivity
            }
            
            // Add company days view controller
            else if let addCompanyDaysEnabledViewController = signupNavigationController.topViewController as? AddCompanyDaysEnabledViewController {
                print("AddCompanyDaysEnabledViewController stateRestorationActivity")
                return addCompanyDaysEnabledViewController.continuationActivity
            }
            
            // Add company hours view controller
            else if let addCompanyHoursEnabledViewController = signupNavigationController.topViewController as? AddCompanyHoursEnabledViewController {
                print("AddCompanyHoursEnabledViewController stateRestorationActivity")
                return addCompanyHoursEnabledViewController.continuationActivity
            }
            
        }
        
        return nil
    }
    
    func getTopViewController() -> UIViewController {
        // Gets the top level view controller from the window (the visible view controller)
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first // Get the window that is being shown
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return UIViewController()
    }


}

