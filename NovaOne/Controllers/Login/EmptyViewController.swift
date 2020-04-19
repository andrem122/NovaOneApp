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
    var titleLabelText: String?
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTitle()
    }
    
    func setupTitle() {
        // Sets the text for the title label
        self.titleLabel.text = self.titleLabelText
    }
    
}
