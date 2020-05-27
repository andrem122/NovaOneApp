//
//  AddCompanyNameViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddCompanyNameViewController: BaseLoginViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar(for: self, navigationBar: nil, navigationItem: nil)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
