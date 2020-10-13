//
//  ContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: Properties
    var alertService = AlertService()
    var homeTabBarSelectIndex: Int? // The selectIndex is passed to the tab bar controller when the app is LAUNCHED from a notification
    var homeTabBarNotificationCount: Int? // The notfication count is passed to the tab bar controller when the app is LAUNCHED from a notification
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let globalMenuNavigationController = segue.destination as? UINavigationController {
            guard let homeTabBarController = globalMenuNavigationController.viewControllers.first as? HomeTabBarController else {
                print("could not get homeTabBarController - ContainerViewController")
                return
            }
            
            guard let selectIndex = self.homeTabBarSelectIndex else {
                print("could not get selectIndex - ContainerViewController")
                return
            }
            
            guard let notificationCount = self.homeTabBarNotificationCount else {
                print("could not get selectIndex - ContainerViewController")
                return
            }
            
            homeTabBarController.selectIndex = selectIndex
            homeTabBarController.notificationCount = notificationCount
        }
    }

}
