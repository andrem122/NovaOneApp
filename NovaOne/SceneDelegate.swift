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
        
        // If we have a NSUserActivity object from a previous opening of the app
        if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
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
                guard
                    let startViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController
                else { return }
                
                // Set root controller for the window
                self.window?.rootViewController = startViewController
                
                // Make the window the key window and visible to the user after setting it up above
                window?.makeKeyAndVisible()
                
                // Get view controllers to recreate navigation sign up stack
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
                
                // Setup transparent navigation bar for sign up stack
                signupEmailViewController.setupNavigationBar()
                
                // Setup sign up navigation controller stack
                let signupNavigationController = UINavigationController(rootViewController: signupEmailViewController)
                signupNavigationController.modalPresentationStyle = .fullScreen
                signupNavigationController.viewControllers = [signupEmailViewController, signupPasswordViewController, signupNameViewController, signupPhoneViewController]
                
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
                    // For the sign up name view controller
                    // Continue from where the user left off
                    signupPhoneViewController.continueFrom(activity: activity)
                    
                    startViewController.present(signupNavigationController, animated: true, completion: nil)
                    signupNavigationController.popToViewController(signupPhoneViewController, animated: true)
                    
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

