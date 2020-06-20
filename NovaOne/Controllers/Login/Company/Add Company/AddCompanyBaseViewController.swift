//
//  AddCompanyBaseViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/16/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyBaseViewController: UIViewController {

    // MARK: Properties
    let alertService = AlertService()
    var embeddedViewController: UIViewController?
    var company: CompanyModel?
    
    func setupNavigationBar() {
        // Setup the navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}
