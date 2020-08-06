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
            print("STATE RESTORATION ACTIVITY")
            print(activity.persistentIdentifier)
            // Get the window object to show the view to restore
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)

            // Detect what view controller we left out on by the activity identifier
            if activity.persistentIdentifier == "SignUpEmailViewController" {
                
            }
            
            let mainStoryboard = UIStoryboard(name: Defaults.StoryBoards.main.rawValue, bundle: .main)
            let signupStoryboard = UIStoryboard(name: Defaults.StoryBoards.signup.rawValue, bundle: .main)
            guard
                let startViewController = mainStoryboard.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController,
                let signupEmailViewController = signupStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.signUpEmail.rawValue) as? SignUpEmailViewController
            else { print("Scene Delegate willConnectTo could not get view controllers"); return }
            
            
            self.window?.rootViewController = startViewController
            
            // Make the window the key window and visible to the user after setting it up above
            window?.makeKeyAndVisible()
            
            let signupNavigationController = UINavigationController(rootViewController: signupEmailViewController)
            signupEmailViewController.continueFrom(activity: activity)
            signupNavigationController.modalPresentationStyle = .fullScreen
            startViewController.present(signupNavigationController, animated: true, completion: nil)
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
        if let signupNavigationController = topController as? UINavigationController,
            let signupEmailViewController = signupNavigationController.viewControllers.first as? SignUpEmailViewController {
            print("SignUpEmailViewController stateRestorationActivity")
            print(signupEmailViewController.continuationActivity.persistentIdentifier)
            return signupEmailViewController.continuationActivity
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

