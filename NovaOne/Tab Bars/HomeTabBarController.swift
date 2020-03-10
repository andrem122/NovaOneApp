//
//  NovaOneTabBar.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/25/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    var customer: CustomerModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let homeViewController = segue.destination as? HomeViewController {
            homeViewController.customer = self.customer
        }
        
    }*/

}
