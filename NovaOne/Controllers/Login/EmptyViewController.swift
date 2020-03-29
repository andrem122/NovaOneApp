//
//  EmptyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupTitle(title: String) {
        self.titleLabel.text = title
    }
    
}
